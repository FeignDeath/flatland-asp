% step(identifier,stepnumber,position), identifier is start + number
step((U,0),0,U) :- initialstate(_,U,_).

trans("N",0).trans("E",1).trans("S",2).trans("W",3).

step(I,N+1,W) :- step(I,N,V), 1 {edge(V,_)} 1, edge(V,W), time(N+1).
step((U,I*4+M),N+1,W) :- step((U,I),N,V), 2 {edge(V,_)}, edge(V,W), W=(_,D), trans(D,M), time(N+1).

path((U,G,I),N) :- initialstate(A,U,_), target(A,G,_), step((U,I),N,(G,D)).
path((U,G,I),N,V) :- path((U,G,I),_), step((U,I'),N,V), 1 {I/4**T = I': T = 0..15}.

1 {assign(A,T,(U,G,I)): path((U,G,I),N), time(T), T>=T1, T>0, T+N<=T2} 1 :- initialstate(A,U,T1), target(A,G,T2).

% no colisions
:- path(I1,N1,(P,_)), path(I2,N2,(P,_)), assign(A1,T1,I1), assign(A2,T2,I2), A1<A2, I1+N1 = I2+N2.


#show assign/3.




% move(G,0,(G,D),"End") :- target(A,G,_), vertex((G,D)).
% move(I,N+1,U,move(I,N,V,M)) :- move(I,N,V,M), edge(U,V), time(N+1).

% path((S,G),M) :- move(G,N+1,S,M), target(A,G,_), initialstate(A,S,_).

% 1 {assign(A,T,path((S,G),move(I,N,V,M))): path((S,G),move(I,N,V,M)), time(T), T+N<=T2, T>=T1, T>0} 1 :- initialstate(A,S,T1), target(A,G,T2).

% move(A,N1,V1,_), move(A,N2,V2,_)

% #show goals(X) : X = #sum{1,P: target(_,P,_)}.
% #show moves(X) : X = {move(_,_,_,_)}.
% #show horizon(X) : time(X), not time(X+1).
% #show paths(X) : X = {path(I,_)}, path(I,_).
% #show assign/3.
% #show.