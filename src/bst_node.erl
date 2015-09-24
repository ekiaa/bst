-module(bst_node).

-behaviour(get_object).

-export([init/1, handle_msg/2, terminate/2]).

-export([create/0]).

create() ->
	gen_object:new(?MODULE, null).

init(Parent) ->
	Object = gen_object:inherit(?MODULE),
	% lager:debug("[init] Parent: ~p", [Parent]),
	{return, Object#{
		parent => Parent,
		left => null,
		right => null,
		key => null,
		value => null
	}}.

handle_msg({insert, #{key := NKey, value := Value, ref := Ref, reply_to := ReplyTo}} = Message, Object) ->
	case Object of
		#{key := null} ->
			ReplyTo ! {Ref, {ok, self()}},
			{return, ok, Object#{key => NKey, value => Value}};
		#{key := Key} when NKey == Key ->
			ReplyTo ! {Ref, {ok, self()}},
			{return, ok, Object#{value => Value}};
		#{key := Key, left := null} when NKey < Key ->
			Left = gen_object:new(?MODULE, self()),
			gen_object:cast(Left, Message),
			{return, ok, Object#{left => Left}};
		#{key := Key, left := Left} when NKey < Key ->
			gen_object:cast(Left, Message),
			{return, ok};
		#{key := Key, right := null} when NKey > Key ->
			Right = gen_object:new(?MODULE, self()),
			gen_object:cast(Right, Message),
			{return, ok, Object#{right => Right}};
		#{key := Key, right := Right} when NKey > Key ->
			gen_object:cast(Right, Message),
			{return, ok}
	end;

handle_msg(_Msg, _Object) ->
	appeal.

terminate(_Reason, _Object) ->
	ok.