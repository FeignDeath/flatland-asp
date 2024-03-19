% goal constraint
% this goal only checks if the goal is reached in the given horizon it doesn not check whether a train reaches his goal in time
goal(A) :- state(A,(P,_),T'), T'<=T, target(A,P,T).
:- agent(A), not goal(A).

% collision forbidance constraint
:- state(A1,(P,_),T), state(A2,(P,_),T), A1<A2.
% no swapping
:- state(A1,U,T1), state(A1,V,T2), {T1<T<T2: state(A1,_,T)} 0, weighted_edge(U,V,T2-T1,_), opposed_edge((U,V,T2-T1),(W,X,_)),
    state(A2,W,TT1), state(A2,X,TT2), {TT1<T<TT2: state(A2,_,T)} 0, T1<=TT1<=T2.