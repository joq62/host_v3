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
-module(install).   
 
-export([hosts/0,
	 etcd/0
	]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
hosts()->
    % This code should be in cluster that creates the initial set up
    % 1.0 Start local and needed applications 
    
    % Check available hosts
    HostInfoList=db_host_spec:read_all(),
    {Available,_Missing}=lib_host:check_hosts_status(HostInfoList),
    Result=case Available of
	       []->
		   {error,[no_hosts_available]};
	       Available->
		   CreateResult=[{lib_host:create_load_host(Host),Host}||Host<-Available],
		   % {{ok,Node,Dir},Host}
		   CreateResult
		 
	   end,
    Result.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
etcd()->
    application:start(common),
    application:start(config),
    ok=application:start(etcd),    
    % Install etcd on this intial node used to create the other host nodes!!
    ok=rpc:call(node(),dbase_lib,dynamic_install_start,[node()],5000),
    ok=rpc:call(node(),db_host_spec,init_table,[node(),node()],10*1000),
    ok=rpc:call(node(),db_application_spec,init_table,[node(),node()],10*1000),
    ok=rpc:call(node(),db_deployment_info,init_table,[node(),node()],10*1000),
    ok=rpc:call(node(),db_deployments,init_table,[node(),node()],10*1000),    
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
