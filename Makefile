all:
	rm -rf  *~ */*~  src/*.beam test/*.beam erl_cra*;
	rm -rf  host_info_specs deployments application_info_specs deployment_info_specs;
	rm -rf Mnesia.*
	rm -rf _build test_ebin ebin;
	rm -rf rebar.lock;
	mkdir ebin;		
	rebar3 compile;	
	cp _build/default/lib/*/ebin/* ebin;
	rm -rf _build test_ebin logs;
	git add -f *;
	git commit -m $(m);
	git push;
	echo Ok there you go!
eunit:
	rm -rf  *~ */*~ src/*.beam test/*.beam test_ebin erl_cra*;
	rm -rf _build logs *.service_dir;
	rm -rf rebar.lock;
	rm -rf  host_info_specs deployments application_info_specs deployment_info_specs;
	rm -rf ebin;
	mkdir test_ebin;
	mkdir ebin;
#	host_info_specs dir and deployments dir shall be installed once
	rm -rf host_info_specs;
	mkdir  host_info_specs;
	cp ../../specifications/host_info_specs/*.host host_info_specs;
	git clone https://github.com/joq62/deployments.git;
	git clone https://github.com/joq62/application_info_specs.git;
	git clone https://github.com/joq62/deployment_info_specs.git;
	rebar3 compile;
	cp _build/default/lib/*/ebin/* ebin;
	erlc -o test_ebin test/*.erl;
	erl -pa ebin -pa test_ebin -sname test -run basic_eunit start -setcookie test_cookie
