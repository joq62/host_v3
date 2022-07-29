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
    io:format("DBG ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    InitNode=node(),
    ok=application:start(config),
    etcd_app:install([InitNode]),
    application:start(etcd),
    mnesia:wait_for_tables([db_application_spec], 20*1000),
    [InitNode]=mnesia:system_info(running_db_nodes),
    io:format("mnesia:system_info ~p~n",[mnesia:system_info()]),

    %% init 
    ok=rpc:call(node(),db_application_spec,init_table,[node(),node()]),
    {ok,"https://github.com/joq62/etcd.git"}=rpc:call(node(),db_application_spec,read,[gitpath,"etcd.spec"]),
    
    io:format("DBG db_application_spec ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    
    ok=rpc:call(node(),db_host_spec,init_table,[node(),node()]),
    ["c100","c200","c201","c202","c300"]=lists:sort(rpc:call(node(),db_host_spec,get_all_hostnames,[])),
 
    io:format("DBG db_host_spec ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    
    ok=rpc:call(node(),db_deployments,init_table,[node(),node()]),
    {ok,["c202"]}=rpc:call(node(),db_deployments,read,[hosts,"solis"]),

    io:format("DBG db_deployments ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    
    ok=rpc:call(node(),db_deployment_info,init_table,[node(),node()]),
    {ok,"solis.depl"}=rpc:call(node(),db_deployment_info,read,[name,"solis.depl"]),
     
    io:format("DBG db_deployment_info ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
     
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
hosts()->
    Nodes=[list_to_atom(HostName++"@"++HostName)||HostName<-db_host_spec:get_all_hostnames()],

    % 1. Stop all host vms
    StoppedHostNodes=[{Node,rpc:call(Node,init,stop,[])}||Node<-Nodes],
      io:format("DBG: StoppedHostNodes ~p~n",[{StoppedHostNodes,?MODULE,?FUNCTION_NAME,?LINE}]),
    % 2. Create host vms and BaseDirs on the living servers
    CreateHostVmList=[{lib_host:create_host_vm(HostName),HostName}||HostName<-lib_host:which_servers_alive()],
    HostNameNodeBaseDirList=[{HostName,Node,BaseDir}|| {{ok,Node,BaseDir},HostName}<-CreateHostVmList],
   
    io:format("DBG:HostNameNodeBaseDirList ~p~n",[{HostNameNodeBaseDirList,?MODULE,?FUNCTION_NAME,?LINE}]),
    
% 3. Clone and load host app
    GitLoadHost=[{lib_host:git_load_host(Node,BaseDir),HostName,Node,BaseDir}||{HostName,Node,BaseDir}<-HostNameNodeBaseDirList],
    HostNameNodeBaseDirApplDirList=[{HostName,Node,BaseDir,ApplDir}|| {{ok,ApplDir},HostName,Node,BaseDir}<-GitLoadHost],
  
    io:format("DBG: HostNameNodeBaseDirApplDirList ~p~n",[{HostNameNodeBaseDirApplDirList,?MODULE,?FUNCTION_NAME,?LINE}]),    

    % 4. Install and start the etcd and mnesia , Choose InitialNode to use for , assume that etcd is running on this node
    SortedHostNodes=lists:sort([Node||{_HostName,Node,_BaseDir,_ApplDir}<-HostNameNodeBaseDirApplDirList]),
    [InitialNode|_]=SortedHostNodes,
    
    io:format("DBG: InitialNode ~p~n",[{InitialNode,?MODULE,?FUNCTION_NAME,?LINE}]),
    
    rpc:call(InitialNode,etcd_app,install,[SortedHostNodes]),
    [rpc:call(Node,application,start,[etcd])||Node<-SortedHostNodes],
    rpc:call(InitialNode,mnesia,wait_for_tables,[[db_application_spec], 20*1000]),
    RunningDbNodes=lists:sort(rpc:call(InitialNode,mnesia,system_info,[running_db_nodes])),
    io:format("DBG:SortedHostNodes ~p~n",[{SortedHostNodes,?MODULE,?FUNCTION_NAME,?LINE}]),
    io:format("DBG:RunningDbNodes ~p~n",[{RunningDbNodes,?MODULE,?FUNCTION_NAME,?LINE}]),
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
