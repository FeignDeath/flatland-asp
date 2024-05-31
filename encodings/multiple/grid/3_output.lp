
% startorder
outputaction(A,2,T) :- starttime(A,T).

% all orders except the startorder are shifted as flatland has a delay of 1
% if an agent stays at the same vertex for the first time a stop action is generated beforehand
outputaction(A,4,T) :- not state(A,P,T-1), state(A,P,T), state(A,P,T+1), state(A,_,T-1).

% if the agent stays longer than one timesteps at the start a stop action is necessary after spawning
outputaction(A,4,T) :- not state(A,_,T-1), state(A,P,T), state(A,P,T+1).

% actions 1 and 3 (left and right turns) are only necessary, if multiple options exist otherwise the trains follows the rails
outputaction(A,1,T) :- state(A,(P,D1),T), state(A,(_,D2),T+1), left(D1,D2) , 2 {transition(P,(D1,_))}.
outputaction(A,3,T) :- state(A,(P,D1),T), state(A,(_,D2),T+1), right(D1,D2), 2 {transition(P,(D1,_))}.

% if the train carries on after stopping an order to continue is given
% it might be that the train continues and should pick a left turn where multiple options are given,
% in that case an action is already provided by the lines above which also serve to continue
outputaction(A,2,T) :- state(A,P,T-1), state(A,P,T), not state(A,P,T+1), not outputaction(A,1,T), not outputaction(A,3,T), state(A,_,T+1).

#show outputaction/3.

% targettime(A,X) :- X = 0..L, target(A,_,L).

% mismatch(A,X) :- time(X), not targettime(A,X), agent(A).
% mismatch(A,X) :- not time(X), targettime(A,X).
% #show mismatch/2.

% #show state(B,C) : state(8,B,C).
% #show.