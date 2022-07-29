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
 
-export([init_node/0,
	 hosts/0,
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
%% Assume that host is loaded and specfication dirs are copied to current vorking dir 
init_node()->
    InitNode=node(),
    ok=application:start(config),
    etcd_app:install([InitNode]),
    application:start(etcd),
    mnesia:wait_for_tables([db_application_spec], 20*1000),
    [InitNode]=mnesia:system_info(running_db_nodes),
    io:format("mnesia:system_info ~p~n",[mnesia:system_info()]),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
hosts()->
    Nodes=[list_to_atom(HostName++"@"++HostName)||HostName<-db_host_spec:get_all_hostnames()],
   
    % 1. Stop all host vms
    [rpc:call(Node,init,stop,[])||Node<-Nodes],
    
    % 2. Create host vms and BaseDirs on the living servers
    CreateHostVm_List=[{lib_host:create_host_vm(HostName),HostName}||HostName<-lib_host:which_servers_alive()],
    HostNameNodeBaseDir_List=[{HostName,Node,BaseDir}|| {{ok,Node,BaseDir},HostName}<-CreateHostVm_List],

    % 3. Clone and load host app
    GitLoadHost=[{lib_host:git_load_host(Node,BaseDir),HostName,Node,BaseDir}||{HostName,Node,BaseDir}<-HostNameNodeBaseDir_List],
    HostNameNodeBaseDirApplDir_List=[{HostName,Node,BaseDir,ApplDir}|| {{ok,ApplDir},HostName,Node,BaseDir}<-GitLoadHost],
    
    % 4. Install and start the etcd and mnesia , Choose InitialNode to use for , assume that etcd is running on this node
    SortedHostNodes=lists:sort([Node||{_HostName,Node,_BaseDir,_ApplDir}<-HostNameNodeBaseDirApplDir_List]),
    [InitialNode|_]=SortedHostNodes,
    
    rpc:call(InitialNode,etcd_app,install,[SortedHostNodes]),
    [rpc:call(Node,application,start,[etcd])||Node<-SortedHostNodes],
    rpc:call(InitialNode,mnesia,wait_for_tables,[[db_application_spec], 20*1000]),
    SortedHostNodes=lists:sort(rpc:call(InitialNode,mnesia,system_info,[running_db_nodes])),
    SortedHostNodes.
    

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
%hosts()->
    % This code should be in cluster that creates the initial set up
    % 1.0 Start local and needed applications 
    
    % Check available servers
 %   HostsAlive=lib_host:which_servers_alive(),
  %  Result=case HostsAlive of
%	       []->
%		   {error,[no_servers_available]};
%	       HostsAlive->
%		   CreateResult=[{lib_host:create_load_host(Host),Host}||Host<-HostsAlive],
%		   % {{ok,Node,Dir},Host}
%		   CreateResult
%		 
%	   end,
 %   Result.

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
