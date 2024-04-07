%% ensuring conflicts are forbidden

% choose who gets priority
1 {resolve((A,(P,D1)),(B,(P,D2))); resolve((B,(P,D2)),(A,(P,D1)))} 1 :- move(A,_,(P,D1)), move(B,_,(P,D2)), A<B.

% forbid swapping
:- resolve((A,(P1,D1)),(B,(P1,D3))), move(A,(P1,D1),(P2,D2)), move(B,(P2,D4),(P1,D3)), not resolve((A,(P2,D2)),(B,(P2,D4))).

% A needs to be at V, before or at the same time as B may enter W
ordering((A,V),(B,W)) :- resolve((A,U),(B,W)), move(A,U,V).
% ordering((A,U),(A,V)) :- move(A,U,V).