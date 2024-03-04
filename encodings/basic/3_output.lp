%% converting the atoms for the import into flatland

% generate the first action without the possibility for a later start
outputaction(A,2,T) :- initialstate(A,(P,D),T), T>0.
outputaction(A,2,1) :- initialstate(A,(P,D),T), T=0.

% if there is a left to be taken generate the left action beforehand
outputaction(A,1,T) :- state(A,_,T,D1), state(A,P,T+1,D2), left(D1,D2), 2 {transition(P,(D1,_))}.
% if there is a right to be taken generate the right action beforehand
outputaction(A,3,T) :- state(A,_,T,D1), state(A,P,T+1,D2), right(D1,D2), 2 {transition(P,(D1,_))}.

#show outputaction/3.