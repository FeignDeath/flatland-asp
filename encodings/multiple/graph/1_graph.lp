% vertices
vertex((P,D)) :- transition(P,(D,_)).
% edges
edge(((X,Y),D1),((X+X',Y+Y'),D2)) :- transition((X,Y),(D1,D2)), movement((X',Y'),D2), vertex(((X+X',Y+Y'),D2)).

% identify choiceless paths
edge(U,V,1) :- edge(U,V).
edge(U,W,N+1) :- edge(U,V,N), edge(V,W,1), {edge(U,_)} 1.
remove(U,V,N) :- edge(U,V,N), edge(V,W,1), {edge(U,_)} 1.
remove(V,W,1) :- edge(U,V,N), edge(V,W,1), {edge(U,_)} 1.

weighted_edge(U,V,N) :- edge(U,V,N), not remove(U,V,N).

#show weighted_edge/3.
#show edge/2.