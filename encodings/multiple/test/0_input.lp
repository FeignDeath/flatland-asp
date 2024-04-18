%% conversion of input atoms

% allowed timesteps limited by latest arrival time
time(0..T+1) :- target(_,_,T).

% agents
agent(A) :- initialstate(A,_,_).

% corresponding movement to every direction
movement((1,0),"S").movement((-1,0),"N").movement((0,1),"E").movement((0,-1),"W").

% direction changes with turns
left("N","W").left("W","S").left("S","E").left("E","N").
right("N","E").right("E","S").right("S","W").right("W","N").