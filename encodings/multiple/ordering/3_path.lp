% start vertex at ealiest possible timestep
state(A,"Start",T) :- T = #max{T': initialstate(A,_,T',_); 1}, initialstate(A,_,_,_).

% if there a conflict ahead where a has to wait, a waits until all agents in conflict have passed
state(A,U,T) :- state(A,U,T-1), allmove(A,U,V), 1 {T<T': state(B,W,T'), ordering((B,W),(A,V))}, U!="End", time(T).

% if an agent does not wait he may move
% if he is at the start node he may leave it but has to wait one timestep after leaving
state(A,V,T) :- state(A,U,T-1), allmove(A,U,V), U=="Start", not state(A,U,T), time(T).
state(A,V,T+1) :- state(A,U,T-1), allmove(A,U,V), U=="Start", not state(A,U,T), time(T).
% if an agent does not wait, and is neither at the start goal, nor does he have to wait, since he ist at the first existing node he follows the path
state(A,V,T) :- state(A,U,T-1), allmove(A,U,V), U!="End", U!="Start", not state(A,"Start",T-2), not state(A,U,T), time(T).

% conversion
state(A,P,T,D) :- state(A,(P,D),T).