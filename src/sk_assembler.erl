%%%----------------------------------------------------------------------------
%%% @author Sam Elliott <ashe@st-andrews.ac.uk>
%%% @copyright 2012 University of St Andrews (See LICENCE)
%%% @doc This module takes a workflow specification, and converts it in into a
%%% set of (concurrent) running processes.
%%%
%%% @end
%%%----------------------------------------------------------------------------
-module(sk_assembler).

-export([
         make/2
        ,run/2
        ]).

-ifdef(TEST).
-compile(export_all).
-endif.

-spec make(skel:workflow(), pid() | module()) -> pid().
make(WorkFlow, EndModule) when is_atom(EndModule) ->
  DrainPid = sk_sink:make(EndModule),
  make(WorkFlow, DrainPid);
make(WorkFlow, EndPid) when is_pid(EndPid) ->
  MakeFns = [parse(Section) || Section <- WorkFlow],
  lists:foldr(fun(MakeFn, Pid) -> MakeFn(Pid) end, EndPid, MakeFns).


-spec run(pid() | skel:workflow(), skel:input()) -> pid().
run (WorkFlow, Input) when is_pid(WorkFlow) ->
  sk_source:make(Input, WorkFlow);
run (WorkFlow, Input) when is_list(WorkFlow) ->
  DrainPid = sk_sink:make(),
  AssembledWF = make(WorkFlow, DrainPid),
  run(AssembledWF, Input).

-spec parse(skel:wf_item()) -> skel:maker_fun().
parse(Fun) when is_function(Fun, 1) ->
  parse({seq, Fun});

parse({seq, Fun})  ->
  sk_seq:make( Fun);
parse({pipe, Proplist}) ->
  sk_pipe:make( Proplist);
parse({ord, Proplist}) ->
  sk_ord:make(Proplist);
parse({farm, WorkFlow, NWorkers}) ->
  sk_farm:make(NWorkers, WorkFlow);
parse({decomp, Proplist}) ->
  sk_decomp:make( Proplist);
parse({map, Proplist }) ->
  sk_map:make( Proplist);
parse({reduce, Proplist}) ->
  sk_reduce:make(Proplist);
parse({feedback, WorkFlow, Filter}) when is_function(Filter, 1) ->
  sk_feedback:make(WorkFlow, Filter).


