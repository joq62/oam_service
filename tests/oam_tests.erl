%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc: : 
%%% Created :
%%% Node end point  
%%% Creates and deletes Pods
%%% 
%%% API-kube: Interface 
%%% Pod consits beams from all services, app and app and sup erl.
%%% The setup of envs is
%%% -------------------------------------------------------------------
-module(oam_tests).      
 
-export([start/0]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),

    ok=setup(),
    ok=test_1(),
    
  
  
    io:format("Stop OK !!! ~p~n",[{?MODULE,?FUNCTION_NAME}]),

    ok.


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
test_1()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),

    ClusterSpec1="c200_c201",
    
    {error,[eexists,"c200_c201",oam,_]}=oam:new_connect_nodes(ClusterSpec1),
    ok=oam:new_db_info(ClusterSpec1),
    ok=oam:new_connect_nodes(ClusterSpec1),
    {ok,PingNodes}=oam:ping_connect_nodes(ClusterSpec1),
   [{pong,'c200_c201_connect@c200'},
    {pong,'c200_c201_connect@c201'}
   ]=lists:sort(PingNodes),
    {error,[already_created,"c200_c201"]}=oam:new_db_info(ClusterSpec1),
 
    ClusterSpec2="single_c200",
    ok=oam:new_db_info(ClusterSpec2),
    ok=oam:new_connect_nodes(ClusterSpec2),
    {ok,PingNodes2}=oam:ping_connect_nodes(ClusterSpec2),
    [{pong,'single_c200_connect@c200'}]=lists:sort(PingNodes2),
  
    ok.


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
-define(ClusterSpec,"c200_c201").
setup()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    {ok,_}=db_etcd_server:start(),
    {ok,_}=resource_discovery_server:start(),
    
    {ok,_}=oam:start(),

    ok.
