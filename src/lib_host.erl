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
-module(lib_host).   
 
-export([

	 is_server_alive/1,
	 is_host_vm_alive/1,
	 is_host_alive/1,

	 which_servers_alive/0,
	 which_servers_dead/0,

	 which_host_vms_alive/0,
	 which_host_vms_dead/0,

	 which_hosts_alive/0,
	 which_hosts_dead/0,

	 check_host_status/1,
	 check_hosts_status/1,
	 
	 
	 create_host_vm/1,
	 git_load_host/2,
	 init_host_apps/1,
	 create_load_start_host/1
	]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
which_hosts_dead()->
    [HostName||HostName<-db_host_spec:get_all_hostnames(),
	       false=:=is_host_alive(HostName)].
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
which_hosts_alive()->
    [HostName||HostName<-db_host_spec:get_all_hostnames(),
	       true=:=is_host_alive(HostName)].
    
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
which_host_vms_dead()->
    [HostName||HostName<-db_host_spec:get_all_hostnames(),
	       false=:=is_host_vm_alive(HostName)].
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
which_host_vms_alive()->
    [HostName||HostName<-db_host_spec:get_all_hostnames(),
	       true=:=is_host_vm_alive(HostName)].
    
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
which_servers_dead()->
    [HostName||HostName<-db_host_spec:get_all_hostnames(),
	       false=:=is_server_alive(HostName)].
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
which_servers_alive()->
    [HostName||HostName<-db_host_spec:get_all_hostnames(),
	       true=:=is_server_alive(HostName)].
    


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
is_host_alive(HostName)->
    HostNode=list_to_atom(HostName++"@"++HostName),
    Bool=case rpc:call(HostNode,host,ping,[]) of
	     {badrpc,_}->
		 false;
	     pong->
		 true
	 end,
    Bool.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
is_host_vm_alive(HostName)->
    HostNode=list_to_atom(HostName++"@"++HostName),
    Bool=case net_adm:ping(HostNode) of
	     pang->
		 false;
	     pong->
		 true
	 end,
    Bool.
			 

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
is_server_alive(HostName)->
    Bool=case check_host_status(HostName) of
	     {[HostName],_}->
		 true;
	     _->
		 false
	 end,
    Bool.				  


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
create_load_start_host(Host)->
    {ok,Node,BaseDir}=create_host_vm(Host),
    {ok,ApplDir}=git_load_host(Node,BaseDir),
    ok=init_host_apps(Node),
    {ok,Node,BaseDir,ApplDir}.

create_host_vm(Host)->
    io:format("DBG ~p~n",[{Host,?MODULE,?FUNCTION_NAME,?LINE}]),
    {Host,Ip,_,Port,User,Password,_}=db_host_spec:read(Host),
    BaseDir=Host,
    NodeName=Host, 
    TimeOut=7000,    
    
    Cookie=atom_to_list(erlang:get_cookie()),
    
    %% Create host vm
    my_ssh:ssh_send(Ip,Port,User,Password,"rm -rf "++BaseDir,TimeOut),
    my_ssh:ssh_send(Ip,Port,User,Password,"mkdir "++BaseDir,TimeOut),
    PaArgs=" -hidden ",
    EnvArgs=" ",
    {ok,Node}=vm:ssh_create(Host,NodeName,Cookie,PaArgs,EnvArgs,
			    {Ip,Port,User,Password,TimeOut}),  
    
    {ok,Node,BaseDir}.

git_load_host(Node,BaseDir)->
    io:format("DBG ~p~n",[{Node,BaseDir,?MODULE,?FUNCTION_NAME,?LINE}]),
    App=host,
    {ok,GitPath}=db_application_spec:read(gitpath,"host.spec"),
    ApplDir=filename:join(BaseDir,atom_to_list(App)),
    ok=rpc:call(Node,file,make_dir,[ApplDir]),
    {ok,Dir}=appl:git_clone_to_dir(Node,GitPath,ApplDir),
    ok=appl:load(Node,App,[filename:join([BaseDir,atom_to_list(App),"ebin"])]),
    {ok,Dir}.

init_host_apps(Node)->
    io:format("DBG ~p~n",[{Node,?MODULE,?FUNCTION_NAME,?LINE}]),
    App=host,
    %% Set up nodes for leader_node                                    
    Nodes=[list_to_atom(HostName++"@"++HostName)||HostName<-db_host_spec:get_all_hostnames()],
    ok=rpc:call(Node,application,set_env,[[{host,[{nodes,Nodes}]}]],5000),
    rpc:call(Node,application,start,[etcd]),
    appl:start(Node,App).
    
			  


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
check_host_status(HostName)->
    {HostName,Ip,IpExt,Port,User,Password,HwApp}=db_host_spec:read(HostName),
    check_hosts_status([{HostName,Ip,IpExt,Port,User,Password,HwApp}],[]).

check_hosts_status(HostInfoList)->
    check_hosts_status(HostInfoList,[]).

check_hosts_status([],HostStatus)->
    Available=[HostName||{HostName,R}<-HostStatus,
			 ok=:=R],
    Missing=[HostName||{HostName,R}<-HostStatus,
		       ok=/=R],
    {lists:sort(Available),lists:sort(Missing)};
check_hosts_status([{HostName,Ip,_IpExt,Port,User,Password,_HwApp}|T],Acc) ->
    TimeOut=10*1000,
    Check=my_ssh:ssh_send(Ip,Port,User,Password,"hostname ",TimeOut),
   % io:format("Host,Check  ~p~n",[{HostName,Check}]),
    NewAcc=case Check of
	       [HostName]->
		   [{HostName,ok}|Acc];
	       ok->
		   [{HostName,ok}|Acc];
	       Reason->
		   [{HostName,[error,Reason]}|Acc]
	   end,
		   
    check_hosts_status(T,NewAcc).
    


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
