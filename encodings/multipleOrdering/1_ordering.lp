start(A,(P,D)) :- initialstate(A,P,_,D).
goal(A,P) :- target(A,P,_).

vertex((P,D)) :- transition(P,(D,_)).
edge(((X,Y),D1),((X+X',Y+Y'),D2)) :- transition((X,Y),(D1,D2)), movement((X',Y'),D2), transition((X+X',Y+Y'),_).

{ move(A,V,U): edge(V,U) } <= 1 :- agent(A), vertex(V).

:- move(A,U,_), not start(A,U), not move(A,_,U).
:- move(A,_,(P,_)), not goal(A,P), not move(A,(P,_),_).
:- start(A,U), move(A,_,U).
:- goal(A,P), move(A,(P,_),_).

:- start(A,(P,_)), not goal(A,P), not move(A,(P,_),_).
:- goal(A,P), not start(A,(P,_)), not move(A,_,(P,_)).