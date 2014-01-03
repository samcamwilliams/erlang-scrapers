-module(buoy_data).
-export([run/0, geth/1]).

run() ->
        inets:start(),
        [
			io:format("~w~n", [extract(URL)])
		||
			{ok, URL} <-
				lists:flatten(
					[
						[ {ok, "http://www.ndbc.noaa.gov/mobile/" ++ Buoy} ||  [Buoy] <- exec_re(Index, "station\.php.+?(?=\")") ]
                	|| Index <-
						[ "http://www.ndbc.noaa.gov/mobile/" ++ Given || [Given] <- exec_re("http://www.ndbc.noaa.gov/mobile/", "region\.php.+?(?=\")") ]
					]
				)
		].

exec_re(Str, Pat) ->
	case re:run(Str, Pat, [{capture, all_but_first, list}]) of
		{match, X} -> X;
		nomatch -> nomatch
	end.

geth(X) ->
        io:format("Getting " ++ X ++ "...~n"),
        case httpc:request(X) of
                {ok, {{_, 200, _}, _, Body}} -> io:format("Got " ++ X ++ "!~n"), Body;
                {error, socket_closed_remotely} -> io:format("Flood reached! Waiting...~n"), timer:sleep(1000), geth(X);
                {error, nxdomain} -> io:format("Flood reached (nx domain)! Waiting...~n"), timer:sleep(1000), geth(X)
        end.

extract(URL) ->
        Content = geth(URL),
        case re:run(Content, "(?<=Seas: )[0-9\.]+?(?= ft)", [{capture, first, list}]) of
                {match, [WVHT]} ->
                        case re:run(Content, "([0-9\.]+?)[NS] ([0-9\.]+?)[WE]", [{capture, all_but_first, list}]) of
                                {match, [North, East]} -> 
									{match, [Bearing, Speed]} = re:run(Content, "(?<=Wind:).*[NSWE] \\(([0-9]*).+?([0-9\.]*) kt", [{capture, all_but_first, list}]),
									{{North, East}, WVHT, {Bearing, Speed}};
                                nomatch -> noll
                        end;
                nomatch -> noht
        end.

