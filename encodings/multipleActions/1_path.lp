1 {starttime(A,T'): time(T'), T'>0, T'>=T, time(T'+2)} 1 :- initialstate(A,_,T,_).
state(A,P,T+1,D) :- initialstate(A,P,_,D), starttime(A,T).
state(A,P,T+2,D) :- initialstate(A,P,_,D), starttime(A,T).
:- state(A,P1,T,_), state(A,P2,T,_), P1>P2.
:- action(A,_,T+1), starttime(A,T).

{action(A,O,T): action(O)} 1 :- state(A,X,T,D), not target(A,X,_).

state(A,(X+X',Y+Y'),T+1,D2) :- state(A,(X,Y),T,D1), transition((X,Y),(D1,D2)), action(A,O,T), action(O,(D1,D2)), movement((X',Y'),D2), time(T+1).
state(A,P,T+1,D) :- state(A,P,T,D), action(A,4,T), time(T+1).