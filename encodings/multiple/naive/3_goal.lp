% this goal checks whether a target can be reached early enough, yet since flatland doesn't alway generate perfectly solvable instances, this might leave to unsatisfiability

goal(A) :- state(A,P,T,_,_), target(A,P,L), T<=L+4.
:- agent(A), not goal(A).