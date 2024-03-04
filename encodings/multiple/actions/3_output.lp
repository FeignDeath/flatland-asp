%% converting the atoms for the import into flatland

% startorder
outputaction(A,2,T) :- starttime(A,T).

% all orders except the startorder are shifted as flatland has a delay of 1
% only the first wait in a row is necessary as the train waits until another action is given
outputaction(A,4,T) :- action(A,4,T+1), not action(A,4,T).

% actions 1 and 3 (left and right turns) are only necessary, if multiple options exist otherwise the trains follows the rails
outputaction(A,1,T) :- action(A,1,T+1), state(A,(P,D),T+1), 2 {transition(P,(D,_))}.
outputaction(A,3,T) :- action(A,3,T+1), state(A,(P,D),T+1), 2 {transition(P,(D,_))}.

% if the train carries on after stopping an order to continue is given
% it might be that the train continues and should pick a left turn where multiple options are given,
% in that case an action is already provided by the lines above which also serve to continue
outputaction(A,2,T) :- action(A,2,T+1), action(A,4,T), not action(A,1,T+1), not action(A,3,T+1).


#show outputaction/3.