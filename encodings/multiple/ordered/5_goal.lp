% the goal must be reached in time
goal(A) :- state(A,"End",T'), T'<=T+1, target(A,_,T).

% goal(A) :- state(A,(P,_),T'), T'<=T, target(A,P,T).
:- agent(A), not goal(A).