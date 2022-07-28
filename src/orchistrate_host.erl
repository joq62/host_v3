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
-module(orchistrate_host).   
 
-export([start/0
	]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
    % This code should be in cluster that creates the initial set up
    % 1.0 Start local and needed applications 
    
    % Check available servers
    Result=case lib_host:which_hosts_dead() of
	       []->
		   {ok,desired_state};
	       DeadHosts->
		   rpc:cast(node(),nodelog,log,[notice,?MODULE_STRING,?LINE,
						{"DEBUG,DeadHosts  ",DeadHosts}]),
		   CreateResult=[{Host,spawn(fun()->create(Host) end)}||Host<-DeadHosts],
		   rpc:cast(node(),nodelog,log,[notice,?MODULE_STRING,?LINE,
						{"DEBUG,CreateResult  ",CreateResult}]),
		   CreateResult
		 
	   end,
    Result.


create(Host)->
    {ok,Node,_Dir}=lib_host:create_load_host(Host),
    ok=rpc:call(Node,application,start,[etcd]),
 %   ok=dbase_lib:dynamic_install([Node],node()),
    ok.
    
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
