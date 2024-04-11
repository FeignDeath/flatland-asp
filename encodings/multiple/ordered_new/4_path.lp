% start vertex at earliest possible timestep
state(A,"Start",T) :- T = #max{T': initialstate(A,_,T'); 1}, agent(A).

% if the agent moves to the start cell it has to wait at least one timestep
state(A,U,T) :- state(A,U,T-1), state(A,"Start",T-2), U!="Start", time(T).

% an agent may wait or continue along his path
block(B,V,T) :- ordering((A,U),(B,V)), state(A,U,T).
block(B,V,T) :- block(B,V,T+1), time(T).
state(B,U,T) :- state(B,U,T-1), move(B,U,V), time(T), block(B,V,T).

state(A,V,T) :- state(A,U,T-1), move(A,U,V), not state(A,U,T), time(T).