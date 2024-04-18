% flow filling
tstate(A,"Start",T) :- T = #max{T': initialstate(A,_,T'); 1}, agent(A).
tstate(A,V,T+1) :- move(A,U,V), tstate(A,U,T-1), tstate(A,"Start",T-2), U!="Start".

tstate(A,V,T) :- tstate(A,U,T-1), move(A,U,V).
tstate(B,W,T) :- resolve((A,U),(B,W)), move(A,U,V), tstate(A,V,T).


state(A,"Start",T) :- T = #max{T': initialstate(A,_,T'); 1}, agent(A).
state(A,U,T) :- move(A,_,U), T = #max{T': tstate(A,U,T')}.
state(A,U,T) :- state(A,U,T-1), move(A,U,V), not state(A,V,T).