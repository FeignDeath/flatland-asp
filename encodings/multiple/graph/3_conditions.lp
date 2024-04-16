%% ensuring the path reaches the goal and conflicts are forbidden

% the goal must be reached in time
goal(A) :- state(A,(P,_),T'), T'<=T+4, target(A,P,T).
:- agent(A), not goal(A).

% collisions are forbidden
:- state(A1,(P,_),T), state(A2,(P,_),T), A1<A2.

% swapping is forbidden
:- state(A1,(P1,_),T), state(A1,(P2,_),T+1), state(A2,(P2,_),T), state(A2,(P1,_),T+1), A1<A2.