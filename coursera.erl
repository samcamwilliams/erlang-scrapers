-module(coursera).
-export([course/1]).

get_page(URL) ->
	case httpc:request(URL) of
		{ok, {{_, 200, _}, _, Body}} -> Body;
		_ -> error
	end.

course(URL) ->
	inets:start(),
	ssl:start(),
	{match, Lectures} =
		re:run(
			get_page(URL ++ "/lecture/preview"),
			"https...class.coursera.org.[a-z\-]+.lecture.preview_view.([0-9]+)",
			[global, {capture, all_but_first, list}]
		),
	lists:map(fun(X) -> lecture(URL, X) end, Lectures).

lecture(BURL, ID) ->
	{match, [Video]} =
		re:run(
			get_page(BURL ++ "/lecture/preview_view?lecture_id=" ++ ID),
			"<source type=.video.webm. src=.(.+).>",
			[global, {capture, all_but_first, list}]
		),
	io:format("~s~n", [Video]).
