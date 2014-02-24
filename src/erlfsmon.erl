-module(erlfsmon).
-export([subscribe/0, subscribe/2, known_events/0, path/0, start_logger/0]).

subscribe(Module, Arg) ->
  gen_event:add_handler(erlfsmon_events, Module, [Arg]).


subscribe() ->
  gen_event:add_sup_handler(erlfsmon_events, {erlfsmon_event_bridge, self()}, [self()]).

known_events() ->
    gen_server:call(erlfsmon, known_events).

path() ->
  % io:format("PATH IS ~p~n", application:get_env(erlfsmon, path)),
  case application:get_env(erlfsmon, path) of
      {ok, P} -> filename:absname(P);
      undefined -> filename:absname("")
  end.

% start_logger() ->
%     spawn(fun() -> subscribe(), logger_loop() end).



start_logger() ->
    spawn(fun() -> logger_loop() end).

logger_loop() ->
    receive
        {_Pid, {erlfsmon, file_event}, {Path, Flags}} ->
            error_logger:info_msg("file_event: ~p ~p", [Path, Flags]);
        _ -> ignore
    end,
    logger_loop().
