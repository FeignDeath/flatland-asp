% flow filling
tstate(A,"Start",T) :- T = #max{T': initialstate(A,_,T'); 1}, agent(A).
tstate(A,U,T) :- tstate(A,U,T-1), U!="Start", tstate(A,"Start",T-2).

tstate(A,V,T) :- tstate(A,U,T-1), move(A,U,V).
tstate(B,V,T) :- resolve((A,U),(B,W)), move(B,V,W), tstate(A,U,T).

state(A,U,T) :- move(A,U,_), T = #max{T':tstate(A,U,T')}.
state(A,V,T) :- state(A,V,T+1), move(A,U,V), not state(A,U,T).