-module(xkcd).
-export([run/0, get_img/2]).

run() -> run(1).
run(404) -> run(405);
run(X) ->
	io:format("~p~n", ["http://www.xkcd.com/" ++ integer_to_list(X) ++ "/"]),
	case httpc:request("http://www.xkcd.com/" ++ integer_to_list(X) ++ "/") of
		{ok, {_, _, Body}} -> spawn(xkcd, get_img, [X, Body]), run(X+1);
		{error, Err} ->
			io:format("ERROR: ~p~n", [Err]),
			wait(3000),
			run(X)
	end.

get_img(Y, Text) ->
	{match, [[X]]} = re:run(Text, "Image URL .for hotlinking/embedding.: (.*)",[global,{capture,[1],list}]),
	case httpc:request(X) of
		{ok, {_, _, Img}} ->
			file:write_file("xkcd/" ++ integer_to_list(Y) ++ ".jpg", Img);
		{error, Err} ->
			io:format("IERROR: ~p~n", [Err]),
			wait(3000),
			get_img(Y, Text)
	end.

wait(X) ->
	receive
		_ -> stop
	after X -> ok
	end.
