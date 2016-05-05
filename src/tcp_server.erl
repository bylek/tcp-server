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
    {tcp, ASocket, <<"quit">>} ->
      gen_tcp:close(ASocket);
    {tcp, ASocket, <<"value=",X/binary>>} ->
      Value = list_to_integer(binary_to_list(X)),
      Return = Value * Value,
      gen_tcp:send(ASocket, "Result square: "++list_to_binary(integer_to_list(Return))),
      handler(ASocket);
    {tcp, ASocket, BinaryMsg} ->
      if
        (BinaryMsg =:= <<"Ping">>) ->
          gen_tcp:send(ASocket, "Pong");
        true ->
          gen_tcp:send(ASocket, "Huh?")
      end,
      handler(ASocket)
  end.
