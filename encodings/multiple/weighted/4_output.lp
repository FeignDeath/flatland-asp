%% converting the atoms for the import into flatland

% startorder
outputaction(A,2,T) :- starttime(A,T).

% all orders except the startorder are shifted as flatland has a delay of 1
% if an agent stays at the same vertex for the first time a stop action is generated beforehand
outputaction(A,4,T) :- state(A,V,T+1), state(A,V,T+2), not state(A,V,T), not initialstate(A,V,_).

% if the agent stays longer than two timesteps at the start a stop action is necessary after spawning
outputaction(A,4,T) :- not state(A,_,T-1), state(A,V,T), state(A,V,T+2).

% actions 1 and 3 (left and right turns) are only necessary, if multiple options exist otherwise the trains follows the rails
% if a move occurs, where multiple moves are possible and the first field is not in the same direction
outputaction(A,1,T) :- move(A,((P,D1),V,N,D2),T+1), left(D1,D2), 2 {weighted_edge((P,D1),_,_,_)}.
outputaction(A,3,T) :- move(A,((P,D1),V,N,D2),T+1), right(D1,D2), 2 {weighted_edge((P,D1),_,_,_)}.
% outputaction(A,1,T) :- state(A,(P1,D1),T+1), state(A,(_,D2),T+2), left(D1,D2), 2 {edge((P1,D1),_)}.
% outputaction(A,3,T) :- state(A,(P1,D1),T+1), state(A,(_,D2),T+2), right(D1,D2), 2 {edge((P1,D1),_)}.

% if the train carries on after stopping an order to continue is given
% it might be that the train continues and should pick a left turn where multiple options are given,
% in that case an action is already provided by the lines above which also serve to continue
outputaction(A,2,T) :- state(A,V,T), state(A,V,T+1), not state(A,V,T+2),
    not outputaction(A,1,T), not outputaction(A,3,T),
    not outputaction(A,2,T-1), % only possible when spawning the train, prevents generation of unnecessary actions
    V = (P,_), not target(A,P,_). % no order necessary if stopped state is the goal state

#show outputaction/3.