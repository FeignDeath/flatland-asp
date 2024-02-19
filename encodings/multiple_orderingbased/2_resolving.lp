allmove(A,V,U) :- move(A,V,U).
allmove(A,V,U) :- initialmove(A,V,U).
allmove(A,V,U) :- finalmove(A,V,U).

1 {resolve((A,U),(B,V)); resolve((B,V),(A,U))} 1 :- allmove(A,_,U), U = (P,_), V = (P,_), allmove(B,_,V), A<B, U!="End", V!="End".
ordering((A,W),(B,V)) :- resolve((A,U),(B,V)), allmove(A,U,W).
% #show resolve/2.