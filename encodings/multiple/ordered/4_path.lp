% start vertex at earliest possible timestep
state(A,"Start",T) :- T = #max{T': initialstate(A,_,T'); 1}, agent(A).

% if there a conflict ahead where a has to wait, a waits until all agents in conflict have passed
{state(A,U,T)} :- state(A,U,T-1), move(A,U,V), ordering(_,(A,V)), time(T).
:- ordering((A,U),(B,V)), state(A,U,T1), state(B,V,T2), T1>T2.
% if the agent moves to the start cell it has to wait at least one timestep
state(A,U,T) :- state(A,U,T-1), state(A,"Start",T-2), U!="Start", time(T).

% otherwise the agent moves along his path
state(A,V,T) :- state(A,U,T-1), move(A,U,V), not state(A,U,T), time(T).
