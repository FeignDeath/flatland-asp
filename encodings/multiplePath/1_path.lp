1 {starttime(A,T'): time(T'), T'>0, T'>=T, time(T'+2)} 1 :- initialstate(A,_,T,_).
state(A,P,T+1,D) :- initialstate(A,P,_,D), starttime(A,T).
state(A,P,T+2,D) :- initialstate(A,P,_,D), starttime(A,T).


1 {state(A,(X+N*X',Y+N*Y'),T+1,D2): movement((X',Y'),D2), transition((X,Y),(D1,D2)), N=0..1} 1 :- state(A,(X,Y),T,D1), time(T+1), not target(A,(X,Y),_).