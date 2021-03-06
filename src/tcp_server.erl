%%%-------------------------------------------------------------------
%%% @author bylek
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. May 2016 19:36
%%%-------------------------------------------------------------------
-module(tcp_server).
-author("bylek").

%% API
-export([start_server/1]).

start_server(Port) ->
  Pid = spawn_link(fun() ->
    {ok, LSocket} = gen_tcp:listen(Port, [binary, {packet, 0}, {active, false}]),
    spawn(fun() -> accept_state(LSocket) end),
    timer:sleep(infinity)
  end),
  {ok, Pid}.

accept_state(LSocket) ->
  {ok, ASocket} = gen_tcp:accept(LSocket),
  spawn(fun() -> accept_state(LSocket) end),
  handler(ASocket).

handler(ASocket) ->
  inet:setopts(ASocket, [{active,once}]),
  receive
    {tcp, ASocket, Msg} ->
      gen_tcp:send(ASocket, Msg),
      handler(ASocket)
  end.
