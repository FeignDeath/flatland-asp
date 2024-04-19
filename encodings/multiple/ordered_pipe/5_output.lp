% output needs to be swapped

% startorder
outputaction(A,2,T) :- state(A,"Start",T), not state(A,"Start",T+1).

% all orders except the startorder are shifted as flatland has a delay of 1
% if an agent stays at the same vertex for the first time a stop action is generated beforehand
outputaction(A,4,T) :- not state(A,P,T), state(A,P,T+1), state(A,P,T+2), not state(A,"Start",T), P!="Start".

% if the agent stays longer than two timesteps at the start a stop action is necessary after spawning
outputaction(A,4,T) :- state(A,"Start",T-1), state(A,P,T), state(A,P,T+2), P!="Start".

% actions 1 and 3 (left and right turns) are only necessary, if multiple options exist otherwise the trains follows the rails
outputaction(A,1,T) :- state(A,(P,D1),T+1), state(A,(_,D2),T+2), left(D1,D2), 2 {transition(P,(D1,_))}.
outputaction(A,3,T) :- state(A,(P,D1),T+1), state(A,(_,D2),T+2), right(D1,D2), 2 {transition(P,(D1,_))}.

% if the train carries on after stopping an order to continue is given
% it might be that the train continues and should pick a left turn where multiple options are given,
% in that case an action is already provided by the lines above which also serve to continue
outputaction(A,2,T) :- state(A,P,T), state(A,P,T+1), not state(A,P,T+2), not outputaction(A,1,T), not outputaction(A,3,T), not outputaction(A,2,T-1), state(A,_,T+2), P!="Start".

#show outputaction/3.