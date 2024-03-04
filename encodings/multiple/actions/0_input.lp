%% conversion of input atoms

% allowed timesteps limited by latest arrival time
time(0..T) :- target(_,_,T).

% agents
agent(A) :- initialstate(A,_,_).

% corresponding movement to every direction
movement((1,0),"S").movement((-1,0),"N").movement((0,1),"E").movement((0,-1),"W").

% possible directions
direction("N").direction("E").direction("S").direction("W").

% direction changes with turns
left("N","W").left("W","S").left("S","E").left("E","N").
right("N","E").right("E","S").right("S","W").right("W","N").

% simple actions
action(1..4).

% define meaning of actions
action(1,(X,Y)) :- left(X,Y).
action(2,(X,X)) :- direction(X).
action(3,(X,Y)) :- right(X,Y).