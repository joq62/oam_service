%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : resource discovery accroding to OPT in Action 
%%% This service discovery is adapted to 
%%% Type = application 
%%% Instance ={ip_addr,{IP_addr,Port}}|{erlang_node,{ErlNode}}
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(oam).
 
-behaviour(gen_server).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
-define(HeartbeatTime,20*1000).

%% External exports
-export([
	 new/2,
	 update/3,
	 delete/2,
	 
	 new_cluster/1,
	 delete_cluster/1,
	 ping_connect_nodes/1,

	 new_db_info/1,
	 new_connect_nodes/1,
	 new_controllers/1,
	 new_workers/1,
	 

	 ping/0
	]).


-export([
	 start/0,
	 stop/0
	]).


%% gen_server callbacks



-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%%-------------------------------------------------------------------
-record(state,{
	       cluster_specs
	      }).


%% ====================================================================
%% External functions
%% ====================================================================

	    
%% call
start()-> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop()-> gen_server:call(?MODULE, {stop},infinity).

new(AppSpec,HostSpec)->
    gen_server:call(?MODULE, {new,AppSpec,HostSpec},infinity).
update(AppSpec,PodNode,HostSpec)->
    gen_server:call(?MODULE, {update,AppSpec,PodNode,HostSpec},infinity).
delete(AppSpec,PodNode)->
    gen_server:call(?MODULE, {delete,AppSpec,PodNode},infinity).



new_db_info(ClusterSpec)->
    gen_server:call(?MODULE, {new_db_info,ClusterSpec},infinity).
new_connect_nodes(ClusterSpec)->
    gen_server:call(?MODULE, {new_connect_nodes,ClusterSpec},infinity).
new_controllers(ClusterSpec)->
    gen_server:call(?MODULE, {new_controllers,ClusterSpec},infinity).
new_workers(ClusterSpec)->
    gen_server:call(?MODULE, {new_workers,ClusterSpec},infinity).
	 
new_cluster(ClusterSpec)->
    gen_server:call(?MODULE, {new_cluster,ClusterSpec},infinity).
delete_cluster(ClusterInstance)->
    gen_server:call(?MODULE, {delete_cluster,ClusterInstance},infinity).

ping_connect_nodes(ClusterSpec)->
    gen_server:call(?MODULE, {ping_connect_nodes,ClusterSpec},infinity).

ping() ->
    gen_server:call(?MODULE, {ping}).
%% cast

%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) -> 
    io:format("Started Server ~p~n",[{?MODULE,?LINE}]),
   
    db_etcd:install(),
    db_cluster_instance:create_table(),
    {ok, #state{ cluster_specs=[]}}.   
 

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_call({new,AppSpec,HostSpec},_From, State) ->
    Reply=ops_appl_operator_server:new(AppSpec,HostSpec),
    
    {reply, Reply, State};

handle_call({delete,AppSpec,PodNode},_From, State) ->
    Reply=ops_appl_operator_server:delete(AppSpec,PodNode),
  
    {reply, Reply, State};

handle_call({update,AppSpec,PodNode,HostSpec},_From, State) ->
    Reply=case ops_appl_operator_server:delete(AppSpec,PodNode)of
	      {error,Reason}->
		  {error,Reason};
	      ok->
		  ops_appl_operator_server:new(AppSpec,HostSpec)
	  end,
		  
    {reply, Reply, State};

handle_call({new_db_info,ClusterSpec},_From, State) ->
    Reply=case lists:keymember(ClusterSpec,1,State#state.cluster_specs) of
	      true->
		  NewState=State,
		  {error,[already_created,ClusterSpec]};
	      false->
		  InstanceId=erlang:integer_to_list(os:system_time(microsecond),36)++"_id",
		  case ops_connect_operator_server:create_dbase_info(ClusterSpec,InstanceId) of
		      ok->
			  NewState=State#state{cluster_specs=[{ClusterSpec,InstanceId}|State#state.cluster_specs]},
			  ok;
		      {error,Reason} ->
			  NewState=State,
			  {error,Reason} 
		  end
	  end,
 {reply, Reply, NewState};

handle_call({new_connect_nodes,ClusterSpec},_From, State) ->
    Reply= case lists:keyfind(ClusterSpec,1,State#state.cluster_specs) of
	       false->
		   NewState=State,
		   {error,[eexists,ClusterSpec,?MODULE,?LINE]};
	       {ClusterSpec,InstanceId}->
		   CurrentCookie=erlang:get_cookie(),
		   {ok,Cookie}=db_cluster_spec:read(cookie,ClusterSpec),
		   erlang:set_cookie(node(),list_to_atom(Cookie)),
		   ops_connect_operator_server:create_connect_nodes(ClusterSpec,InstanceId),
		   erlang:set_cookie(node(),CurrentCookie),
		   NewState=State#state{cluster_specs=[{ClusterSpec,InstanceId}|State#state.cluster_specs]},
		   ok
	  end,
 {reply, Reply, NewState};

handle_call({new_controllers,ClusterSpec},_From, State) ->
    Reply= case lists:keyfind(ClusterSpec,1,State#state.cluster_specs) of
	       false->
		   {error,[eexists,ClusterSpec,?MODULE,?LINE]};
	       {ClusterSpec,InstanceId}->
		   CurrentCookie=erlang:get_cookie(),
		   {ok,Cookie}=db_cluster_spec:read(cookie,ClusterSpec),
		   erlang:set_cookie(node(),list_to_atom(Cookie)),
		   ops_pod_operator_server:create_controller_pods(ClusterSpec,InstanceId),
		   erlang:set_cookie(node(),CurrentCookie),
		   ok
	   end,
    {reply, Reply, State};

handle_call({new_workers,ClusterSpec},_From, State) ->
    Reply= case lists:keyfind(ClusterSpec,1,State#state.cluster_specs) of
	       false->
		   {error,[eexists,ClusterSpec,?MODULE,?LINE]};
	       {ClusterSpec,InstanceId}->
		   CurrentCookie=erlang:get_cookie(),
		   {ok,Cookie}=db_cluster_spec:read(cookie,ClusterSpec),
		   erlang:set_cookie(node(),list_to_atom(Cookie)),
		   ops_pod_operator_server:create_worker_pods(ClusterSpec,InstanceId),
		   erlang:set_cookie(node(),CurrentCookie),
		   ok
	   end,
    {reply, Reply, State};

handle_call({ping_connect_nodes,ClusterSpec},_From, State) ->
    Reply= case lists:keyfind(ClusterSpec,1,State#state.cluster_specs) of
	       false->
		   {error,[eexists,ClusterSpec,?MODULE,?LINE]};
	       {ClusterSpec,InstanceId}->
		   CurrentCookie=erlang:get_cookie(),
		   {ok,Cookie}=db_cluster_spec:read(cookie,ClusterSpec),
		   erlang:set_cookie(node(),list_to_atom(Cookie)),
		   ConnectNodes=db_cluster_instance:nodes(connect,InstanceId),
		   PingConnectNodes=[{net_adm:ping(Node),Node}||Node<-ConnectNodes],
		   erlang:set_cookie(node(),CurrentCookie),
		  
		   {ok,PingConnectNodes}
	   end,
    {reply, Reply, State};

handle_call({delete_cluster,ClusterInstance},_From, State) ->
    Reply=pong,
    {reply, Reply, State};

handle_call({ping},_From, State) ->
    Reply=pong,
    {reply, Reply, State};


handle_call(Request, From, State) ->
    Reply = {unmatched_signal,?MODULE,Request,From},
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(Msg, State) ->
    io:format("unmatched match cast ~p~n",[{Msg,?MODULE,?LINE}]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info({ssh_cm,_,_}, State) ->
    {noreply, State};

handle_info(Info, State) ->
    io:format("unmatched match~p~n",[{Info,?MODULE,?LINE}]), 
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
