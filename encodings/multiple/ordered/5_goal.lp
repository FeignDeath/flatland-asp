% the goal must be reached in time
goal(A) :- state(A,"End",T'), T'<=T+1, target(A,_,T).

% goal(A) :- state(A,(P,_),T'), T'<=T, target(A,P,T).
:- agent(A), not goal(A).

% no swapping
% :- state(A1,(P1,_),T), state(A1,(P2,_),T+1), state(A2,(P2,_),T), state(A2,(P1,_),T+1), A1<A2.