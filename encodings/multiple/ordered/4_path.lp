% start vertex at earliest possible timestep
state(A,"Start",T) :- T = #max{T': initialstate(A,_,T'); 1}, agent(A).

% if the agent moves to the start cell it has to wait at least one timestep
state(A,U,T) :- state(A,U,T-1), state(A,"Start",T-2), U!="Start", time(T).

% an agent may wait or continue along his path
{state(A,U,T)} :- state(A,U,T-1), move(A,U,V), time(T).
state(A,V,T) :- state(A,U,T-1), move(A,U,V), not state(A,U,T), time(T).

% agent must conform the the ordering
:- resolve((A,U),(B,W)), move(A,U,V), state(A,V,T1), state(B,W,T2), T1>T2.