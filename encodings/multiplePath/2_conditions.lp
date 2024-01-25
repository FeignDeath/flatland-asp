% goal constraint
% this goal only checks if the goal is reached in the given horizon it doesn not check whether a train reaches his goal in time
goal(A) :- state(A,P,_,_), target(A,P,_).
:- agent(A), not goal(A).

% collision forbidance constraint
:- state(A1,P,T,_), state(A2,P,T,_), A1<A2.
% no swapping
:- state(A1,P1,T,_), state(A1,P2,T+1,_), state(A2,P2,T,_), state(A2,P1,T+1,_), A1<A2.