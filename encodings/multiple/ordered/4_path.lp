% start vertex at earliest possible timestep
state(A,"Start",T) :- T = #max{T': initialstate(A,_,T'); 1}, agent(A).

% replaces waiting and cnforming with the ordering
% reduces grounding but blows up solving, if not combined with same direction simplification in conflicts
% wait(A,U,T) :- ordering((B,V),(A,U)), state(B,V,T+1).
% wait(A,U,T) :- wait(A,U,T+1), time(T).
% state(A,U,T) :- state(A,U,T-1), move(A,U,V), wait(A,V,T).


% if the agent moves to the start cell it has to wait at least one timestep
state(A,U,T) :- state(A,U,T-1), state(A,"Start",T-2), U!="Start", time(T).

% an agent may wait or continue along his path
{state(A,U,T)} :- state(A,U,T-1), move(A,U,V), time(T).
state(A,V,T) :- state(A,U,T-1), move(A,U,V), not state(A,U,T), time(T).

% agent must conform the the ordering
:- ordering((A,U),(B,V)), state(A,U,T1), state(B,V,T2), T1>T2.