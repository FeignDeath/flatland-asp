%% find conflicts

% number the paths
% path(Vertex, DistFromStart, ID (Start+Number))
path(S,1,(S,N)) :- move(S,S,V,N).
path(S,2,(S,N)) :- move(S,S,V,N).
path(V,T+1,(S,N)) :- path(U,T,(S,N)), move(S,U,V,N), not path(U,T+1,(S,N)), V!="End".

% determine conflicts
% vertex
conflict(I1,I2,T1-T2) :- path((P,_),T1,I1), path((P,_),T2,I2), I1>=I2.
% swap
conflict(I1,I2,T1-T2) :- path((P1,_),T1,I1), path((P2,_),T1+1,I1), path((P2,_),T2,I2), path((P1,_),T2+1,I2), I1>=I2.

% assign a path to each train
1 {assign(A,I,T'): path(U,1,I), target(A,P,_), path((P,_),_,I), time(T'), T' >= T} 1 :- initialstate(A,U,_), T = #max{TS: initialstate(A,U,TS);1}.

% make sure they are on time
:- assign(A,I,T1), path(U,T2,I), not time(T1+T2).

% make sure they don't conflict
:- conflict(I1,I2,TC), assign(A1,I1,T1), assign(A2,I2,T2), A1!=A2, T1+TC = T2.
