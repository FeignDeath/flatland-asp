% step(identifier,stepnumber,position), identifier is start + number
step((U,0),0,U) :- initialstate(_,U,_).

trans("N",1).trans("E",2).trans("S",3).trans("W",4).

step(I,N+1,W) :- step(I,N,V), 1 {edge(V,_)} 1, edge(V,W), time(N+1).
step((U,I*5+M),N+1,W) :- step((U,I),N,V), 2 {edge(V,_)}, edge(V,W), W=(_,D), trans(D,M), time(N+1).

path((U,G,I),N) :- initialstate(A,U,_), target(A,G,_), step((U,I),N,(G,D)).
path((U,G,I),N',V) :- path((U,G,I),N), step((U,I'),N',V), 1 {I/5**T = I': T = 0..15}.