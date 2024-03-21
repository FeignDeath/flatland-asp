% the goal must be reached in time
goal(A) :- state(A,(P,_),T'), T'<=T, target(A,P,T).
:- agent(A), not goal(A).

% no swapping
:- fmove(A,E,T1), fmove(B,F,T2), A!=B, opposed_edge(E,F,N), T1<=T2<=T1+N.