%% ensuring goals are reached and conflicts enforced

% goal must be reached
goal(A) :- state(A,(P,_),_), target(A,P,_).
:- agent(A), not goal(A).

% no vertex conflicts
:- state(A1,(P,_),T), state(A2,(P,_),T), A1<A2.

% no swap conflicts
:- state(A1,(P1,_),T), state(A1,(P2,_),T+1), state(A2,(P2,_),T), state(A2,(P1,_),T+1), A1<A2.