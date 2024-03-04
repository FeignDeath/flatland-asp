%% generating a path via actions

% choose a time for an agent to spawn, whereat he appears and stays at least one timestep
1 {starttime(A,T'): time(T'), T'>0, T'>=T, time(T'+2)} 1 :- initialstate(A,_,T).
state(A,(P,D),T+1) :- initialstate(A,(P,D),_), starttime(A,T).
state(A,(P,D),T+2) :- initialstate(A,(P,D),_), starttime(A,T).

% for every timestep where an agent exists there may be an action if the goal is not reached yet
{action(A,O,T): action(O)} 1 :- state(A,(X,D),T), not target(A,X,_).
% if there exists an action at a timestep the agent moves correspondingly
state(A,((X+X',Y+Y'),D2),T+1) :- state(A,((X,Y),D1),T), transition((X,Y),(D1,D2)), action(A,O,T), action(O,(D1,D2)), movement((X',Y'),D2), time(T+1).
% if there is an action the agent waits one timestep
state(A,U,T+1) :- state(A,U,T), action(A,4,T), time(T+1).

% no action may be created for the first timestep the agent appeared
:- action(A,_,T+1), starttime(A,T).