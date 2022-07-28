%%% -------------------------------------------------------------------
%%% Author  : joqerlang
%%% Description :
%%% load,start,stop unload applications in the pods vm
%%% supports with services
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(host).  

-behaviour(gen_server).  

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("kernel/include/logger.hrl").

%% --------------------------------------------------------------------
-define(SERVER,?MODULE).
-define(LogDir,"logs").
-define(DeplSpecExtension,".depl_spec").
-define(Interval,30*1000).

%% External exports
-export([

	 install/0,
	 

	 is_server_alive/1,
	 check_host_status/1,
	 create_load_host/1,
	 
	 cluster_id/0,
	 
	 desired_state_check/0,

	 appl_start/1,
	 ping/0
	]).


-export([
	 start/0,
	 stop/0
	]).


-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {
		deployment_name,
		start_time=undefined
	       }).

%% ====================================================================
%% External functions
%% ====================================================================
appl_start([])->
    application:start(?MODULE).

%% ====================================================================
%% Server functions
%% ====================================================================
%% Gen server functions

start()-> gen_server:start_link({local, ?SERVER}, ?SERVER, [], []).
stop()-> gen_server:call(?SERVER, {stop},infinity).

%% ====================================================================
%% Application handling
%% ====================================================================


%%---------------------------------------------------------------
%% Function:template()
%% @doc: service spec template  list of {app,vsn} to run      
%% @param: 
%% @returns:[{app,vsn}]
%%
%%---------------------------------------------------------------
%-spec template()-> [{atom(),string()}].
%template()->
 %   gen_server:call(?SERVER, {template},infinity).


%% ====================================================================
install()-> 
    gen_server:call(?SERVER, {install},infinity).


is_server_alive(HostName)->
    gen_server:call(?SERVER, {is_server_alive,HostName},infinity).

check_host_status(HostName)->
    gen_server:call(?SERVER, {check_host_status,HostName},infinity).

create_load_host(HostName)->
    gen_server:call(?SERVER, {create_load_host,HostName},infinity).

cluster_id()-> 
    gen_server:call(?SERVER, {cluster_id},infinity).
%% 
%% @doc:check if service is running
%% @param: non
%% @returns:{pong,node,module}|{badrpc,Reason}
%%
-spec ping()-> {atom(),node(),module()}|{atom(),term()}.
ping()-> 
    gen_server:call(?SERVER, {ping},infinity).


desired_state_check()->
    gen_server:cast(?SERVER, {desired_state_check}).

%% ====================================================================
%% Gen Server functions
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
    case application:get_env(nodes) of
	undefined->
	    started_in_install_mode;
	{ok,Nodes}->
	    application:set_env([{leader_node,[{nodes,Nodes}]}]),
	    ok=application:start(leader_node)
    end,
    {ok, #state{
	    start_time={date(),time()}
	   }
    }.

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

handle_call({is_server_alive,HostName},_From, State) ->
    Reply=lib_host:is_server_alive(HostName),
    {reply, Reply, State};

handle_call({check_host_status,HostName},_From, State) ->
    Reply=lib_host:check_host_status(HostName),
    {reply, Reply, State};

handle_call({create_load_host,HostName},_From, State) ->
    Reply=lib_host:create_load_host(HostName),
    {reply, Reply, State};

handle_call({install},_From, State) ->
    Reply=install:start(),
 %   io:format("mnesia:system_info() ~p~n",[rpc:call(node(),mnesia,system_info,[])]),
    {reply, Reply, State};

handle_call({ping},_From, State) ->
    Reply=pong,
    {reply, Reply, State};

handle_call({stopped},_From, State) ->
    Reply=ok,
    {reply, Reply, State};


handle_call({not_implemented},_From, State) ->
    Reply=not_implemented,
    {reply, Reply, State};

handle_call({stop}, _From, State) ->
    {stop, normal, shutdown_ok, State};

handle_call(Request, From, State) ->
    %rpc:cast(node(),log,log,[?Log_ticket("unmatched call",[Request, From])]),
    Reply = {ticket,"unmatched call",Request, From},
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------



handle_cast({desired_state_check}, State) ->
    spawn(fun()->local_desired_state_check(State#state.deployment_name) end),
    {noreply, State};

handle_cast(_Msg, State) ->
  %  rpc:cast(node(),log,log,[?Log_ticket("unmatched cast",[Msg])]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info({nodedown,Node}, State) ->
    io:format(" ~p~n",[{?MODULE,?LINE,nodedown,Node}]),
    {noreply, State};


handle_info({ssh_cm,_,_}, State) ->
  %  io:format("ssh_cm ~p~n",[{?MODULE,?LINE}]),
    {noreply, State};

handle_info(Info, State) ->
    io:format("Info ~p~n",[{?MODULE,?LINE,Info}]),
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

local_desired_state_check(DeploymentName)->	
    timer:sleep(?Interval),
    case leader:am_i_leader(node()) of
	true->
	    rpc:call(node(),k3_node_orchistrate,desired_state,[DeploymentName],5*60*1000);
	false ->
	    ok
    end,
    rpc:cast(node(),k3_node,desired_state_check,[]).
