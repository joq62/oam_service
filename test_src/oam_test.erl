%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(oam_test).  
    
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
-include("log.hrl").
%% --------------------------------------------------------------------
-export([start/0]).

%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:emulate loader
%% Description: requires pod+container module
%% Returns: non
%% --------------------------------------------------------------------
start()->
    send_msg(),
    all(),
    error(),
    event(),    
    ok.




%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
%-define(LOG_INFO(Type,Msg),log_service:msg({Type,[node(),?MODULE,?FILE,?LINE,date(),time(),Msg]})).


send_msg()->
    log_service:msg({error,[node(),?MODULE,?FILE,?LINE,{2020,12,25},{15,00,00},'error 1']}),
 %   log_service:msg({error,[node(),?MODULE,?FILE,?LINE,{2019,12,24},{15,00,00},'error 2']}),
 %   log_service:msg({error,[node(),?MODULE,?FILE,?LINE,{2020,12,24},{15,00,00},'error 3']}),
 %   log_service:msg({event,[node(),?MODULE,?FILE,?LINE,{2019,12,24},{14,59,59},'event 1']}), 
    ok.    

all()->
    glurk=dns_service:get("log_service"),
    Node=node(),
    ?assertMatch({ok,[{in,{'$gen_cast',{msg,{error,[Node,?MODULE,?FILE,_,{2020,12,25},{15,00,00},'error 1']}}}},
		      {noreply,{state}}
		     ]},log_service:get(all)),

    ?assertMatch({ok,[{in,{'$gen_cast',{msg,{error,[Node,?MODULE,?FILE,_,_,_,'error 1']}}}},
		      {noreply,{state}}
		     ]},oam_service:log_get(all)),
    ok.


error()->
 %   ?assertMatch([{error,[log_test@asus,log_test,"test_src/log_test.erl",Line1,Date_1,_Time1,'error 1']},
%		  {error,[log_test@asus,log_test,"test_src/log_test.erl",Line2,Date2,_Time2,'error 2']}],log_service:get(error)),
    ok.

event()->
 %   ?assertMatch([{event,[log_test@asus,log_test,"test_src/log_test.erl",Line1,Date_1,_Time1,'event 1']},
%		  {event,[log_test@asus,log_test,"test_src/log_test.erl",Line2,Date2,_Time2,'event 2']}],log_service:get(event)),
    ok.
