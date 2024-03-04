%% ensuring the path reaches the goal

% this goal only checks if the goal is reached in the given horizon it doesn not check whether a train reaches his goal in time
goal(A) :- state(A,P,_,_), target(A,P,_).
:- agent(A), not goal(A).