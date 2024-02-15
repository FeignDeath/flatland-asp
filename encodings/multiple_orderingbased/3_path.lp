time(0..T) :- T == {ordering(_,_)}.

state(A,U,T) :- ordering((A,U),_), not ordering(_,(A,U)), initialstate(A,_,T-1,_).
state(A,U,T) :- state(A,U,T-1), initialstate(A,P,_,D), U=(P,D), not state(A,U,T-2), time(T).
state(B,V,T) :- ordering((A,U),(B,V)), state(A,U,T1), T-1 == #max{T1;T2}, initialstate(B,_,T2,_), time(T-T2), 1 {not initialstate(A,P,_,D): U=(P,D); state(A,U,T-2)}.

state(A,P,T,D) :- state(A,(P,D),T).