%% ensuring the path reaches the goal and conflicts are forbidden

% goal constraint
goal(A) :- state(A,(P,_),_), target(A,P,_).
:- agent(A), not goal(A).

% collision forbidance constraint
:- state(A1,(P,_),T), state(A2,(P,_),T), A1<A2.

% no swapping
:- move(A,E,T1), move(B,F,T2), A!=B, opposed_edge(E,F,N), T1<=T2<=T1+N.