-module(sk_utils_test).

-compile(export_all).

-include_lib("eunit/include/eunit.hrl").


start_workers_shoul_create_N_workers_test() ->

  %% given
  meck:new(sk_utils,[passthrough]),
  meck:expect(sk_utils, start_worker, 2, pid),
  NumOfWorkers = 10,

  %% when
  Workers = sk_utils:start_workers( NumOfWorkers, work_flow, next_pid),

  %% then
  ?assertEqual( NumOfWorkers,
                length( Workers )),
  ?assert( meck:validate( sk_utils )),
  ?assertEqual( NumOfWorkers,
                meck:num_calls( sk_utils, start_worker,'_')),

  meck:unload(sk_utils).


stop_workers_should_stop_all_workers_test() ->

  %% given
  meck:new(sk_utils,[passthrough]),
  meck:expect(sk_utils, stop_worker, 1, {system, eos}),
  NumOfWorkers = 10,
  Workers = lists:seq(1, NumOfWorkers),

  %% when
  sk_utils:stop_workers( ?MODULE, Workers ),

  %% then
  ?assert( meck:validate( sk_utils )),
  ?assertEqual( NumOfWorkers,
                meck:num_calls( sk_utils, stop_worker,'_')),
  ?assertEqual( 1,
                meck:num_calls( sk_utils, stop_worker, [1])),
  ?assertEqual( 1,
                meck:num_calls( sk_utils, stop_worker, [NumOfWorkers])),

  meck:unload(sk_utils).

