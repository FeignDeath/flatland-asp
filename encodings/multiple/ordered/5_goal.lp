% the goal must be reached in time
goal(A) :- state(A,"End",_), agent(A).
:- agent(A), not goal(A).