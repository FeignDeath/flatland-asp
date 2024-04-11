%% ensuring conflicts are forbidden

% choose who gets priority
1 {resolve((A,(P,D1)),(B,(P,D2))); resolve((B,(P,D2)),(A,(P,D1)))} 1 :- move(A,_,(P,D1)), move(B,_,(P,D2)), A<B.

% forbid swapping
:- resolve((A,(P1,D1)),(B,(P1,D3))), move(A,(P1,D1),(P2,D2)), move(B,(P2,D4),(P1,D3)), not resolve((A,(P2,D2)),(B,(P2,D4))).

% simplification when moving in the same direction
:- resolve((A,U),(B,V)), move(A,U,W), move(B,V,W), W!="End", not resolve((A,W),(B,W)).

% removing lock when ignoring transitivity
:- resolve((A,U),(B,V)), resolve((B,V),(C,W)), resolve((C,W),(A,V)).

% A needs to be at V, before or at the same time as B may enter W
ordering((A,U),(B,W)) :- resolve((A,U),(B,W)), {resolve((A,U),(C,V)): resolve((C,V),(B,W))} 0.
% ordering((A,U),(A,V)) :- move(A,U,V).