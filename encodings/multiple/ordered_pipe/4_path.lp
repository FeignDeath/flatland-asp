%% generating a path from the moveset before

% flow filling
% start
tstate(A,"Start",T) :- T = #max{T': initialstate(A,_,T'); 1}, agent(A).

% add state with moves and resolves
tstate(A,V,T) :- tstate(A,U,T-1), move(A,U,V).
tstate(B,V,T) :- resolve((A,U),(B,W)), move(B,V,W), tstate(A,U,T).

% resulting states are the highest ones
state(A,U,T) :- move(A,U,_), T = #max{T':tstate(A,U,T')}.

% fill the gaps with waiting
state(A,V,T) :- state(A,V,T+1), move(A,U,V), not state(A,U,T).