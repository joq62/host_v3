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
    ok=application:start(host),
    io:format("install:etcd()  ~p~n",[install:etcd()]),
    
    io:format("servers_alive   ~p~n",[lib_host:which_servers_alive()]),
    io:format("servers_dead   ~p~n",[lib_host:which_servers_dead()]),

    io:format("host_vms_alive   ~p~n",[lib_host:which_host_vms_alive()]),
    io:format("host_vms_dead   ~p~n",[lib_host:which_host_vms_dead()]),

    io:format("hosts_alive   ~p~n",[lib_host:which_hosts_alive()]),
    io:format("hosts_dead   ~p~n",[lib_host:which_hosts_dead()]),

    io:format("c100   ~p~n",[host:is_server_alive("c100")]),
    io:format("c200   ~p~n",[host:is_server_alive("c200")]),
    io:format("c201   ~p~n",[host:is_server_alive("c201")]),
    io:format("c202   ~p~n",[host:is_server_alive("c202")]),
    io:format("c300   ~p~n",[host:is_server_alive("c300")]),
    io:format("TEST OK! ~p~n",[?MODULE]),
  %  timer:sleep(1000),
 %   init:stop(),
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

setup()->
  
    % Simulate host
  %  R=rpc:call(node(),test_nodes,start_nodes,[],2000),
%    [Vm1|_]=test_nodes:get_nodes(),

%    Ebin="ebin",
 %   true=rpc:call(Vm1,code,add_path,[Ebin],5000),
 
   % R.
    ok.
