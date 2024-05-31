%% generating a path via actions

% choose a time for an agent to spawn, whereat he appears and stays at least one timestep
1 {starttime(A,T'): T'=T..L, T'>0} 1 :- initialstate(A,_,T), target(A,_,L).
state(A,(P,D),T+1) :- initialstate(A,(P,D),_), starttime(A,T).

% an agent may take an allowed move if neither goal nor horizon is reached
{state(A,((X+X',Y+Y'),D2),T+1): movement((X',Y'),D2), transition((X,Y),(D1,D2))} :- state(A,((X,Y),D1),T), target(A,_,L), T+1<=L, not target(A,(X,Y),_).
% an agent may wait a timestep if neither goal nor horizon is reached
{state(A,(P,D),T+1)} :- state(A,(P,D),T), target(A,_,L), T+1<=L, not target(A,P,_).
% only one agent per timestep
:- 2 {state(A,_,T)}, state(A,_,T).