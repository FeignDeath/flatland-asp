allmove(A,V,U) :- move(A,V,U).
allmove(A,V,U) :- initialmove(A,V,U).
allmove(A,V,U) :- finalmove(A,V,U).

1 {resolve(A,B,U); resolve(B,A,U)} 1 :- allmove(A,_,U), allmove(B,_,U), A<B, U!="End".

ordering((A,U),(A,V)) :- allmove(A,U,V).
ordering((A,V),(B,U)) :- resolve(A,B,U), allmove(A,U,V).