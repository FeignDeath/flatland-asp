% translates the path into actions for the train and dissallows some impossible combinations as far as I now

outputaction(A,T-1,2) :- state(A,_,T,_,_,_), not state(A,_,_,T-1,_,_).

% if there is a left to be take generate the left action beforehand
outputaction(A,T-1,1) :- state(A,P,_,T,D1,D2), left(D1,D2), 2 {transition(P,(D1,_))}.
% accalerate so the train can leave in the next timestep (the last not excludes the special case at the beginning)
outputaction(A,T2-1,2) :- state(A,_,T1,T2,_,_), T2-T1>0, initialstate(A,_,TI,_), T1>TI+1, not action(A,T2-1,1), not action(A,T2-1,3), not action(A,T2-2,2).
% if there is a right to be take generate the right action beforehand
outputaction(A,T-1,3) :- state(A,P,_,T,D1,D2), right(D1,D2), 2 {transition(P,(D1,_))}.
% stop before entering if the train should wait on this cell (the last not excludes the first situation)
outputaction(A,T1-1,4) :- state(A,_,T1,T2,_,_), T2-T1>0, initialstate(A,_,TI,_), T1>TI+1, not action(A,T1-1,2).

% at most one action per timestep (should not be necessary)
% :- action(A,T,O1), action(A,T,O2), O1<O2.

#show outputaction/3.