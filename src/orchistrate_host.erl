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
		   CreateResult=[{lib_host:create_load_host(Host),Host}||Host<-DeadHosts],
		   CreateResult
		 
	   end,
    Result.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
