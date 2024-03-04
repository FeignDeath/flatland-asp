%% generating timesteped paths through the graph

% spawning the agent
1 {starttime(A,T'): time(T'), T'>0, T'>=T, time(T'+2)} 1 :- initialstate(A,_,T).
state(A,V,T+1) :- initialstate(A,V,_), starttime(A,T).
state(A,V,T+2) :- initialstate(A,V,_), starttime(A,T).

% moving
{state(A,V,T) : edge((P,D),V)} :- state(A,(P,D),T-1), time(T), not target(A,P,_).
% staying
{state(A,(P,D),T)} :- state(A,(P,D),T-1), time(T), not target(A,P,_).
% only one agent per timestep
:- 2 {state(A,_,T)}, agent(A), time(T).