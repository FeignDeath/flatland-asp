%% ensuring conflicts are forbidden

% choose who gets priority
1 {resolve((A,(P,D1)),(B,(P,D2))); resolve((B,(P,D2)),(A,(P,D1)))} 1 :- move(A,_,(P,D1)), move(B,_,(P,D2)), A<B.
% transitivity
% :- resolve(A,B), resolve(B,C), A!=B, B!=C, A!=C, not resolve(A,C).

% A needs to be at V, before or at the same time as B may enter W
ordering((A,V),(B,W)) :- resolve((A,U),(B,W)), move(A,U,V).
% ordering((A,U),(A,V)) :- move(A,U,V).