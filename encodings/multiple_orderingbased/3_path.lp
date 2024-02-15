time(0..T) :- T == {ordering(_,_)}.

state(A,"Nowhere",T) :- initialstate(A,_,T,_).
1 {state(A,U,T); state(A,V,T)} 1 :- state(A,U,T-1), allmove(A,U,V), time(T).
:- state(A,"Nowhere",T-2), state(A,(P,D),T-1), not state(A,(P,D),T).

goal(A) :- state(A,(P,_),T'), T'<=T, target(A,P,T).
:- agent(A), not goal(A).

% collision forbidance constraint
:- state(A1,(P,_),T), state(A2,(P,_),T), A1<A2.
% no swapping
:- state(A1,(P1,_),T), state(A1,(P2,_),T+1), state(A2,(P2,_),T), state(A2,(P1,_),T+1), A1<A2.

% state(A,U,T) :- ordering((A,U),_), not ordering(_,(A,U)), initialstate(A,_,T-1,_).
% state(A,U,T) :- state(A,U,T-1), initialstate(A,P,_,D), U=(P,D), not state(A,U,T-2), time(T).
% state(B,V,T) :- ordering((A,U),(B,V)), state(A,U,T1), T-1 == #max{T1;T2}, initialstate(B,_,T2,_), time(T-T2), 1 {not initialstate(A,P,_,D): U=(P,D); state(A,U,T-2)}.

% state(A,P,T,D) :- state(A,(P,D),T).

#show state/3.