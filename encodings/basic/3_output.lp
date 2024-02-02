% translates the path into actions for the train and dissallows some impossible combinations as far as I know

% generate the first actions without the possibility for a later start
outputaction(A,T,2) :- initialstate(A,P,T,D), T>0.
outputaction(A,1,2) :- initialstate(A,P,T,D), T=0.

% if there is a left to be take generate the left action beforehand
outputaction(A,T-1,1) :- state(A,_,T-1,D1), state(A,P,T,D2), left(D1,D2), 2 {transition(P,(D1,_))}.
% if there is a right to be take generate the right action beforehand
outputaction(A,T-1,3) :- state(A,_,T-1,D1), state(A,P,T,D2), right(D1,D2), 2 {transition(P,(D1,_))}.

% at most one action per timestep
:- outputaction(A,T,O1), outputaction(A,T,O2), O1!=O2.

#show outputaction/3.