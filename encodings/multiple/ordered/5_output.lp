%% transforms path into actions for flatland
% ignores delays, as every agent faces them

% startorder
outputaction(A,2,T) :- state(A,"Start",T), not state(A,"Start",T+1).

% if an agent stays at the same vertex for the first time a stop action is generated beforehand
outputaction(A,4,T) :- not state(A,P,T-1), state(A,P,T), state(A,P,T+1), P!="Start".

% actions 1 and 3 (left and right turns) are only necessary, if multiple options exist otherwise the trains follows the rails
outputaction(A,1,T) :- state(A,(P,D1),T), state(A,(_,D2),T+1), left(D1,D2) , 2 {transition(P,(D1,_))}.
outputaction(A,3,T) :- state(A,(P,D1),T), state(A,(_,D2),T+1), right(D1,D2), 2 {transition(P,(D1,_))}.

% if the train carries on after stopping an order to continue is given
% it might be that the train continues and should pick a left turn where multiple options are given,
% in that case an action is already provided by the lines above which also serve to continue
outputaction(A,2,T) :- state(A,P,T-1), state(A,P,T), not state(A,P,T+1), not outputaction(A,1,T), not outputaction(A,3,T), state(A,_,T+1), P!="Start".

#show outputaction/3.