% transforming the extracted atoms

% allowed timesteps limited by latest arrival time
time(T) :- target(_,_,T).
time(T) :- time(T+1), T>=0.

% agents
agent(A) :- initialstate(A,_,_,_).

% directions after movement
movement((1,0),"S").movement((-1,0),"N").movement((0,1),"E").movement((0,-1),"W").

% direction changes with turns
left("N","W").left("W","S").left("S","E").left("E","N").
right("N","E").right("E","S").right("S","W").right("W","N").

direction("N").direction("E").direction("S").direction("W").

action(1..4).

action(1,(X,Y)) :- left(X,Y).
action(2,(X,X)) :- direction(X).
action(3,(X,Y)) :- right(X,Y).