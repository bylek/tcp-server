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
-export([start_server/0]).
-define(Port, 9000).

start_server() ->
  Pid = spawn_link(fun() ->
    {ok, LSocket} = gen_tcp:listen(?Port, [binary, {active, false}]),
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
    {tcp, ASocket, <<"quit", _/binary>>} ->
      gen_tcp:close(ASocket);
    {tcp, ASocket, Msg} ->
      gen_tcp:send(ASocket, Msg),
      handler(ASocket)
  end.
