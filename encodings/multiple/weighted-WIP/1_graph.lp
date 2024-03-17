% vertices
vertex((P,D)) :- transition(P,(D,_)).
% edges
edge(((X,Y),D1),((X+X',Y+Y'),D2)) :- transition((X,Y),(D1,D2)), movement((X',Y'),D2).

% identify choiceless paths
edge((P,D),V,1,V,(P,D)) :- edge((P,D),V), 3 {edge((P,_),_)}.
edge(U,V,1,V,U) :- edge(U,V), initialstate(_,U,_).
edge(U,W,N+1,F,(P,D)) :- edge(U,(P,D),N,F,_), edge((P,D),W), {edge((P,_),_)} 2, not initialstate(_,(P,D),_), not target(_,P,_).
remove(U,(P,D),N) :- edge(U,(P,D),N,_,_), {edge((P,_),_)} 2, not initialstate(_,(P,D),_), not target(_,P,_).

weighted_edge(U,V,N) :- edge(U,V,N,_,_), not remove(U,V,N).
% weighted_edge(U,V,1) :- edge(U,V), not remove(_,V,_).

same_edge((U1,V1,N),(U2,V2,N)) :- edge(U1,V1,N,F1,L1), edge(U2,V2,N,F2,L2),
    (P11,_) = U1, (P22,_) = V2, P11==P22,
    (P12,_) = V1, (P21,_) = U2, P12==P21,
    (PF1,_) = F1, (PL2,_) = L2, PF1==PL2,
    (PL1,_) = L1, (PF2,_) = F2, PL1==PF2.

% #show weighted_edge/3.