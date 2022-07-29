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
-module(appl_eunit).   
 
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
-define(PaArgsInit," ").

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
    []=os:cmd("rm -rf "++?TestAddGitDir),
    []=os:cmd("rm -rf "++?TestDiviGitDir),
    

    %
    % vm:create
    % appl:git_clone
    % appl:load
    % appl:start

    {ok,NodeLocal}=vm:create(?HostName,?NodeName,?Cookie,?PaArgsInit,?EnvArgs),
    {ok,AddGitDir}=appl:git_clone(NodeLocal,?TestAddGitPath,?TestAddGitDir),
 
    %% test_add
    ok=appl:load(NodeLocal,test_add,["test_add/ebin"]),
    ok=appl:start(NodeLocal,test_add),
    42=rpc:call(NodeLocal,test_add,add,[20,22]),
    ok=appl:stop(NodeLocal,test_add),
    ok=appl:unload(NodeLocal,test_add,?TestAddGitDir),

    %% test_divi

    {ok,DiviGitDir}=appl:git_clone(NodeLocal,?TestDiviGitPath,?TestDiviGitDir), 
    ok=appl:load(NodeLocal,test_divi,["test_divi/ebin"]),
    ok=appl:start(NodeLocal,test_divi),
    42.0=rpc:call(NodeLocal,test_divi,divi,[420,10]),
    ok=appl:stop(NodeLocal,test_divi),
    ok=appl:unload(NodeLocal,test_divi,?TestDiviGitDir),
    timer:sleep(2000),  
    ok=vm:delete(NodeLocal),
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
