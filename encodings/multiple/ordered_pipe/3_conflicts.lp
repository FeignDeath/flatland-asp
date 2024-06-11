%% ensuring conflicts are forbidden

% choose who gets priority
1 {resolve((A,U),(B,V)); resolve((B,V),(A,U))} 1 :- move(A,_,U), move(B,_,V), U = (P,_), V = (P,_), A<B.

#edge((A,U),(A,V)) : move(A,U,V).
#edge((A,V),(B,W)) : resolve((A,U),(B,W)), move(A,U,V).