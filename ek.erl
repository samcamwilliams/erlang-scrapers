-module(ek).
-export([start/0]).
-record(rep, {
	ship,
	system,
	region,
	sec,
	time
}).
-define(URL, "http://www.eve-kill.net").

start() ->
	inets:start(),
	os:cmd("clear"),
	scrape([]).

page() -> page(?URL).
page(URL) -> page(URL, 0).
page(URL, 3) -> {error, page_unreachable};
page(URL, Attempt) ->
	case httpc:request(URL) of
		{ok, {{_, 200, _}, _, Data}} -> Data;
		_ ->
			io:format("ERROR: Unexpected response, waiting 3 seconds...~n"),
			timer:sleep(3000),
			page(URL, Attempt + 1)
	end.

scrape(Known) ->
	lists:map(
		fun(X) ->
			alert(X)
		end,
		lists:reverse((NewKnown = get_kills()) -- Known)
	),
	timer:sleep(60000),
	scrape(NewKnown).

get_kills() ->
	process_page(page()).

process_page(Str) ->
	{match, Matches} =
		re:run(Str,
			"<div class=\"no_stretch\" style=\"width: 153px;\">.+?<b>(.+?)</b>.+?<b>.*?</b>.+?<b>.*?</b>.+?<div class=\"no_stretch\" style=\"text-align:left; width: 160px; height:auto\">(.+?) / (.+?) .+?>(.+?)<.+?<b>([0-9]{2}:[0-9]{2})</b>",
			[{capture, all_but_first, list}, global, dotall]
		),
	lists:map(
		fun([Ship, Region, System, Sec, Time]) ->
			#rep {
				ship = Ship,
				region = Region,
				system = System,
				sec = Sec,
				time = Time
			}
		end,
		Matches
	).

alert(X) ->
	io:format("~s ~s~s / ~s (~s)~n",
		[
			X#rep.time,
			pad(X#rep.ship, 35),
			X#rep.system,
			X#rep.region,
			X#rep.sec
		]
	).

pad(Str, Len) when length(Str) >= Len -> Str;
pad(Str, Len) ->
	Str ++ [ hd(" ") || _ <- lists:seq(1, Len - length(Str)) ].
