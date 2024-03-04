% vertices
vertex((P,D)) :- transition(P,(D,_)).
% edges
edge(((X,Y),D1),((X+X',Y+Y'),D2)) :- transition((X,Y),(D1,D2)), movement((X',Y'),D2).

% identify choiceless paths
edge(U,V,1) :- edge(U,V), 2 {edge(U,_)}.
edge(U,V,1) :- edge(U,V), initialstate(_,U,_).
edge(U,W,N+1) :- edge(U,V,N), edge(V,W), {edge(V,_)} 1.
remove(U,(P,D),N) :- edge(U,(P,D),N), edge((P,D),W), {edge((P,D),_)} 1, not target(_,P,_).

weighted_edge(U,V,N) :- edge(U,V,N), not remove(U,V,N).
weighted_edge(U,V,1) :- edge(U,V), not remove(_,V,_).