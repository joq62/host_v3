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
-module(basic_eunit).   
 
-export([start/0]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
    ok=initial_landet_eunit:start(),
    io:format("TEST OK! ~p~n",[?MODULE]),
    timer:sleep(1000),
    init:stop(),
    ok.



%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
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
-define(EnvArgs,"-common test_env test").
-define(PaArgsInit,"-pa /home/joq62/erlang/infra_2/common/ebin").


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
list_len()->
    L=[1,a,{34,z},"b",'kalle',<<"a">>],
    6=list_length:start(L),
    ok.


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
map_test()->
 
    F1 = fun square/2,
    F2 = fun sum/3,
    L=[1,2,3,4,5,6,7,8,9],
    [{R,sqr}]=mapreduce:start(F1,F2,[],L),
    io:format(" R ~p~n",[R]).



square(Pid,Tal)->
    Pid!{sqr,Tal*Tal}.



sum(Key,Vals,Acc)->
    [{Vals,Key}|Acc].
    


setup()->
  
    % Simulate host
  %  R=rpc:call(node(),test_nodes,start_nodes,[],2000),
%    [Vm1|_]=test_nodes:get_nodes(),

%    Ebin="ebin",
 %   true=rpc:call(Vm1,code,add_path,[Ebin],5000),
 
   % R.
    ok.
