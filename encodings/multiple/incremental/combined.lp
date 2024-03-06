#include <incmode>.
#const imin = 1.
#const imax = 100.


#program base.

%% input
% agents
agent(A) :- initialstate(A,_,_).

% corresponding movement to every direction
movement((1,0),"S").movement((-1,0),"N").movement((0,1),"E").movement((0,-1),"W").

% direction changes with turns
left("N","W").left("W","S").left("S","E").left("E","N").
right("N","E").right("E","S").right("S","W").right("W","N").


#program step(t).

%% path
% choose a time for an agent to spawn, whereat he appears and stays at least one timestep
{starttime(A,t)} :- initialstate(A,_,T), t>=T.
state(A,(P,D),t) :- initialstate(A,(P,D),_), starttime(A,t-1).
state(A,(P,D),t) :- initialstate(A,(P,D),_), starttime(A,t-2).

% an agent may take an allowed move if neither goal nor horizon is reached
{state(A,((X+X',Y+Y'),D2),t): movement((X',Y'),D2), transition((X,Y),(D1,D2))} :- state(A,((X,Y),D1),t-1), not target(A,(X,Y),_).
% an agent may wait a timestep if neither goal nor horizon is reached
{state(A,(P,D),t)} :- state(A,(P,D),t-1), not target(A,P,_).
% only one agent per timestep
:- 2 {state(A,_,t)}, agent(A).

%% constraints
% set goal if a reached it
goal(A,t) :- state(A,(P,_),t), t<=T, target(A,P,T).

% collisions are forbidden
:- state(A1,(P,_),t), state(A2,(P,_),t), A1<A2.

% swapping is forbidden
:- state(A1,(P1,_),t-1), state(A1,(P2,_),t), state(A2,(P2,_),t-1), state(A2,(P1,_),t), A1<A2.

isTurn(A,t) :- state(A,(P,D1),t-1), state(A,(_,D2),t), D1!=D2, 2 {transition(P,(D1,_))}.


#program check(t).

% only one starttime per agent
:- starttime(A,T1), starttime(A,T2), T1<T2, query(t).

% the goal must be reached in time
:- agent(A), not goal(A,_), query(t), query(t).

%% output
#show.
% startorder
#show outputaction(A,2,T) : starttime(A,T).

% all orders except the startorder are shifted as flatland has a delay of 1
% if an agent stays at the same vertex for the first time a stop action is generated beforehand
#show outputaction(A,4,T) : not state(A,P,T), state(A,P,T+1), state(A,P,T+2), state(A,_,T).

% if the agent stays longer than two timesteps at the start a stop action is necessary after spawning
#show outputaction(A,4,T) : not state(A,_,T-1), state(A,P,T), state(A,P,T+2).

% actions 1 and 3 (left and right turns) are only necessary, if multiple options exist otherwise the trains follows the rails
#show outputaction(A,1,T) : state(A,(P,D1),T+1), state(A,(_,D2),T+2), left(D1,D2), 2 {transition(P,(D1,_))}.
#show outputaction(A,3,T) : state(A,(P,D1),T+1), state(A,(_,D2),T+2), right(D1,D2), 2 {transition(P,(D1,_))}.

% if the train carries on after stopping an order to continue is given
% it might be that the train continues and should pick a left turn where multiple options are given,
% in that case an action is already provided by the lines above which also serve to continue
#show outputaction(A,2,T) : state(A,P,T), state(A,P,T+1), not state(A,P,T+2), not isTurn(A,T+2), not starttime(A,T-1), state(A,_,T+2).




#program base.