-module(bst).

-export([insert/3]).

insert(Tree, Key, Value) ->
	Ref = erlang:make_ref(),
	gen_object:cast(Tree, {insert, #{key => Key, value => Value, ref => Ref, reply_to => self()}}),
	reply(Ref).

reply(Ref) ->
	receive
		{Ref, Result} -> Result
	after
		5000 -> {error, timeout}
	end.