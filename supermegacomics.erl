-module(comicscraper).
-export([run/0]).

run() ->
	inets:start(),
	run(1).
	
run(X) ->
	case httpc:request("http://www.supermegacomics.com/images/" ++ integer_to_list(X) ++ ".gif") of
		{ok, {{_, 200, _}, _, Body}} -> file:write_file("comics/" ++ integer_to_list(X) ++ ".gif", Body), io:format("~w~n", [X]), run(X+1);
		{ok, {{_, 404, _}, _, _}} -> finished;
		{error,socket_closed_remotely} -> io:format("Flood reached! Waiting...~n"), timer:sleep(1000), run(X)
	end.
