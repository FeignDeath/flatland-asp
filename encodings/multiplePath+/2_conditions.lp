% goal constraint
% this goal only checks if the goal is reached in the given horizon it doesn not check whether a train reaches his goal in time
goal(A) :- state(A,P,T',_,_,_), T'<T, target(A,P,T).
:- agent(A), not goal(A).

% collision forbidance constraint
:- state(A1,P,T1,T3,_,_), state(A2,P,T2,_,_,_), A1<A2, T1<=T2, T2<=T3.
% no swapping
:- state(A1,P1,_,T,_,_), state(A1,P2,T+1,_,_,_), state(A2,P2,_,T,_,_), state(A2,P1,T+1,_,_,_), A1<A2.