% goal constraint
% this goal only checks if the goal is reached in the given horizon it doesn not check whether a train reaches his goal in time
goal(A) :- state(A,(P,_),T'), T'<=T, target(A,P,T).
:- agent(A), not goal(A).

% collision forbidance constraint
:- state(A1,(P,_),T), state(A2,(P,_),T), A1<A2.
% no swapping
:- move(A,E,T1), move(B,F,T2), A!=B, opposed_edge(E,F,N), T1<=T2<=T1+N.