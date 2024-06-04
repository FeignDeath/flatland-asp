% confirms goal / path selection
1 {assign(A,T+1,(U,G,S)): path((U,G,S),N), time(T), T>=T1, T>0, T+N<=T2} 1 :- initialstate(A,U,T1), target(A,G,T2).

% vertex conflicts
:- path(I1,N1,(P,_)), path(I2,N2,(P,_)), assign(A1,T1,I1), assign(A2,T2,I2), A1<A2, T1+N1 = T2+N2.

% swap coflicts
:- path(I1,N1,(P1,_)), path(I1,N1+1,(P2,_)), path(I2,N2,(P2,_)), path(I2,N2+1,(P1,_)), assign(A1,T1,I1), assign(A2,T2,I2), A1<A2, T1+N1 = T2+N2.