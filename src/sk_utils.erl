%%%----------------------------------------------------------------------------
%%% @author Sam Elliott <ashe@st-andrews.ac.uk>
%%% @copyright 2012 University of St Andrews (See LICENCE)
%%% @doc This module contains various useful functions for dealing with workers
%%%
%%% @end
%%%----------------------------------------------------------------------------
-module(sk_utils).

-export([
         start_workers/3
        ,start_worker/2
        ,stop_workers/2
        ,stop_worker/1
        ]).


-ifdef(TEST).
-compile(export_all).
-endif.

-spec start_workers(pos_integer(), skel:workflow(), pid()) -> [pid()].
start_workers(NWorkers, WorkFlow, NextPid) ->
  start_workers(NWorkers, WorkFlow, NextPid, _Acc = []).

-spec start_workers(pos_integer(), skel:workflow(), pid(), [pid()]) -> [pid()].
start_workers(NWorkers,_WorkFlow,_NextPid, WorkerPids) when NWorkers < 1 ->
  WorkerPids;
start_workers(NWorkers, WorkFlow, NextPid, WorkerPids) ->
  NewWorker = ?MODULE:start_worker(WorkFlow, NextPid),
  start_workers(NWorkers-1, WorkFlow, NextPid, [NewWorker|WorkerPids]).

-spec start_worker(skel:workflow(), pid()) -> pid().
start_worker(WorkFlow, NextPid) ->
  sk_assembler:make(WorkFlow, NextPid).

-spec stop_workers(module(), [pid()]) -> 'eos'.
stop_workers( Mod, Workers) ->
  lists:map( fun( Worker ) -> 
                 sk_tracer:t(85, self(), Worker, {Mod, system}, [{msg, eos}]),
                 ?MODULE:stop_worker( Worker )
             end,
             Workers ),
  eos.

-spec stop_worker( pid()) -> {system, eos}.
stop_worker( Worker ) ->
  Worker ! {system, eos}.
