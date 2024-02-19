vertex((P,D)) :- transition(P,(D,_)).
edge(((X,Y),D1),((X+X',Y+Y'),D2)) :- transition((X,Y),(D1,D2)), movement((X',Y'),D2).