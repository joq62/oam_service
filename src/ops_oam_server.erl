%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : resource discovery accroding to OPT in Action 
%%% This service discovery is adapted to 
%%% Type = application 
%%% Instance ={ip_addr,{IP_addr,Port}}|{erlang_node,{ErlNode}}
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(ops_oam_server).
 
-behaviour(gen_server).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------


%% External exports
-export([
	]).


-export([
	 start/0,
	 stop/0
	]).


%% gen_server callbacks



-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%%-------------------------------------------------------------------

-record(state,{cluster_spec
	     	      
	      }).


%% ====================================================================
%% External functions
%% ====================================================================

	    
%% call
start()-> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop()-> gen_server:call(?MODULE, {stop},infinity).



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
    db_etcd:install(),
    
    {ok, #state{cluster_spec=undefined}}.   
 

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

handle_call({gitpath,ApplSpec},_From, State) ->
    Reply=db_appl_spec:read(gitpath,ApplSpec),
    {reply, Reply, State};

handle_call({app,ApplSpec},_From, State) ->
    Reply=db_appl_spec:read(app,ApplSpec),
    {reply, Reply, State};


handle_call({appl_name,ApplSpec},_From, State) ->
    Reply=db_appl_spec:read(appl_name,ApplSpec),
    {reply, Reply, State};


handle_call({hostname,HostSpec},_From, State) ->
    Reply=db_host_spec:read(hostname,HostSpec),
    {reply, Reply, State};

handle_call({worker_host_specs,ClusterDeploymentSpec},_From, State) ->
    Reply=db_cluster_deployment:read(worker_host_specs,ClusterDeploymentSpec),
    {reply, Reply, State};

handle_call({application_spec,ApplicationSpec},_From, State) ->
    Reply=db_appl_spec:read(ApplicationSpec),
    {reply, Reply, State};

handle_call({application_deployment_info,ApplDeploymentSpec},_From, State) ->
    Reply=db_appl_deployment:read(ApplDeploymentSpec),
    {reply, Reply, State};

handle_call({cluster_application_deployments,
	     appl_deployment_specs,ClusterApplDeployment},_From, State) ->
    Reply= db_cluster_application_deployment:read(appl_deployment_specs,ClusterApplDeployment),
    
    {reply, Reply, State};
handle_call({cluster_application_deployments,
	     cluster_spec,ClusterSpec},_From, State) ->
    Reply=[SpecId||{SpecId,X_ClusterSpec,_ApplDeploySpecs}<-db_cluster_application_deployment:read_all(),
						       X_ClusterSpec=:=ClusterSpec],
    {reply, Reply, State};

handle_call({cluster_spec},_From, State) ->
    Reply=State#state.cluster_spec,
    {reply, Reply, State};


handle_call({get_state},_From, State) ->
    Reply=State,
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
