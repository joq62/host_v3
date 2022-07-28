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
    io:format("install:hosts()  ~p~n",[install:hosts()]),
    io:format("dbase_lib:dynamic_install_start(IntialNode) ~p~n",[dbase_lib:dynamic_install_start(c100@c100)]),
    io:format("c100 install:etcd()  ~p~n",[rpc:call(c100@c100,install,etcd,[])]),
    io:format("dbase_lib:dynamic_install(Rest,IntialNode) ~p~n",[dbase_lib:dynamic_install ([c200@c200,c202@c202],c100@c100)]),
    

    io:format("c200 mnesia:system_info  ~p~n",[rpc:call(c200@c200,mnesia,system_info,[])]),
    
%    io:format("hosts_alive   ~p~n",[lib_host:which_hosts_alive()]),
%    io:format("hosts_dead   ~p~n",[lib_host:which_hosts_dead()]),
    io:format("c100 who_is_leader ~p~n",[rpc:call(c100@c100,leader_node,who_is_leader,[])]),
    timer:sleep(500),
    io:format("c200 who_is_leader ~p~n",[rpc:call(c200@c200,leader_node,who_is_leader,[])]),
    rpc:call(c100@c100,init,stop,[]),
    timer:sleep(1000),
    io:format("c202 who_is_leader ~p~n",[rpc:call(c202@c202,leader_node,who_is_leader,[])]),
    timer:sleep(1000),
    io:format("c202 who_is_leader ~p~n",[rpc:call(c202@c202,leader_node,who_is_leader,[])]),
     timer:sleep(1000),
    io:format("c202 who_is_leader ~p~n",[rpc:call(c202@c202,leader_node,who_is_leader,[])]),
     timer:sleep(1000),
    io:format("c202 who_is_leader ~p~n",[rpc:call(c202@c202,leader_node,who_is_leader,[])]),
    
    
    
    

 %   io:format("servers_alive   ~p~n",[lib_host:which_servers_alive()]),
 %   io:format("servers_dead   ~p~n",[lib_host:which_servers_dead()]),

 %   io:format("host_vms_alive   ~p~n",[lib_host:which_host_vms_alive()]),
 %   io:format("host_vms_dead   ~p~n",[lib_host:which_host_vms_dead()]),

  

    
   
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
