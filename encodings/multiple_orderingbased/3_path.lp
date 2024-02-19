state(A,"Start",T) :- T = #max{T': initialstate(A,_,T',_); 1}, initialstate(A,_,_,_).
1 {state(A,U,T); state(A,V,T)} 1 :- state(A,U,T-1), allmove(A,U,V), V!="End", time(T).
:- state(A,"Start",T-2), state(A,(P,D),T-1), not state(A,(P,D),T).

:- ordering((A,U),(B,V)), state(A,U,T1), state(B,V,T2), T1>T2.

goal(A) :- state(A,(P,_),T'), T'<=T, target(A,P,T).
:- agent(A), not goal(A).

% collision forbidance constraint
:- state(A1,(P,_),T), state(A2,(P,_),T), A1<A2.
% no swapping
:- state(A1,(P1,_),T), state(A1,(P2,_),T+1), state(A2,(P2,_),T), state(A2,(P1,_),T+1), A1<A2.

state(A,P,T,D) :- state(A,(P,D),T).

% #show state/3.