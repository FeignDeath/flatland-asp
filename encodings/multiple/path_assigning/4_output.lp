%% converting the atoms for the import into flatland
% ignores delays, as every agent faces them

% conversion into states for output generation
state(A,V,T+N) :- assign(A,T,I), path(I,N,V).

% startorder
outputaction(A,2,T) :- assign(A,T+1,_).

% if an agent stays at the same vertex for the first time a stop action is generated
outputaction(A,4,T) :- state(A,V,T), state(A,V,T+1), not state(A,V,T-1).

% actions 1 and 3 (left and right turns) are only necessary, if multiple options exist otherwise the trains follows the rails
outputaction(A,1,T) :- state(A,(P1,D1),T), state(A,(_,D2),T+1), left(D1,D2) , 2 {edge((P1,D1),_)}.
outputaction(A,3,T) :- state(A,(P1,D1),T), state(A,(_,D2),T+1), right(D1,D2), 2 {edge((P1,D1),_)}.

% if the train carries on after stopping an action to continue is given
% if it continues via a turn, that action is already generated by the above and works as an action on its own
outputaction(A,2,T) :- state(A,V,T-1), state(A,V,T), not state(A,V,T+1),
    not outputaction(A,1,T), not outputaction(A,3,T),
    state(A,_,T+1). % no order necessary if stopped state is the goal state

#show outputaction/3.