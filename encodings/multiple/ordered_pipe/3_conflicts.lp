%% ensuring conflicts are forbidden

% choose who gets priority
1 {resolve((A,(P,D1)),(B,(P,D2))); resolve((B,(P,D2)),(A,(P,D1)))} 1 :- move(A,_,(P,D1)), move(B,_,(P,D2)), A<B.

#edge((A,U),(A,V)) : move(A,U,V).
#edge((A,V),(B,W)) : resolve((A,U),(B,W)), move(A,U,V).