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
-module(initial_eunit).   
 
-export([start/0]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(TestAddGitPath,"https://github.com/joq62/test_add.git").
-define(TestAddGitDir,"test_add").
-define(TestDiviGitPath,"https://github.com/joq62/test_divi.git").
-define(TestDiviGitDir,"test_divi").

-define(Ip,"192.168.1.100").
-define(Port,22).
-define(User,"joq62").
-define(Password,"festum01").
-define(TimeOut,6000).

-define(HostName,"c100").
-define(NodeName,"TestVm").
-define(Node,'TestVm@c100').
-define(NodeDir,"test_vm_dir").
-define(Cookie,atom_to_list(erlang:get_cookie())).
-define(EnvArgs," "). 
-define(PaArgsInit,"-pa /home/joq62/erlang/infra_2/host/ebin").

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->

    os:cmd("rm -rf Mnesia.host1@c100"),
    os:cmd("rm -rf Mnesia.host2@c100"),
    os:cmd("rm -rf Mnesia.host3@c100"),    

    {ok,N1}=vm:create("c100","host1",?Cookie,?PaArgsInit,?EnvArgs),
    {ok,N2}=vm:create("c100","host2",?Cookie,?PaArgsInit,?EnvArgs),
    {ok,N3}=vm:create("c100","host3",?Cookie,?PaArgsInit,?EnvArgs),
 
    %% Install 
    ok=rpc:call(N1,dbase_lib,dynamic_install_start,[N1],5000),
    rpc:call(N1,application,start,[config]),
    ok=rpc:call(N1,db_host_spec,init_table,[N1],10*1000),
    ok=rpc:call(N1,db_application_spec,init_table,[N1],10*1000),
    ok=rpc:call(N1,db_deployment_info,init_table,[N1],10*1000),
    ok=rpc:call(N1,db_deployments,init_table,[N1],10*1000),
    timer:sleep(5000),
    ok=rpc:call(N1,dbase_lib,dynamic_install,[[N2,N3],N1],5000),
  
    io:format("mnesia:system_info() ~p~n",[rpc:call(N2,mnesia,system_info,[])]),
  
    %%  
  
    

    %%
    
    io:format("mnesia:system_info() ~p~n",[rpc:call(N1,mnesia,system_info,[])]),

    io:format("TEST OK! ~p~n",[?MODULE]),
    timer:sleep(1000),
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

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
setup()->
  
    % Simulate host
  %  R=rpc:call(node(),test_nodes,start_nodes,[],2000),
%    [Vm1|_]=test_nodes:get_nodes(),

%    Ebin="ebin",
 %   true=rpc:call(Vm1,code,add_path,[Ebin],5000),
 
   % R.
    ok.
