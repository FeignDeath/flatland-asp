%% conversion of input atoms

% agents
agent(A) :- initialstate(A,_,_).

% horizons
horizon(A,T) :- target(A,_,T).

% directions after movement
movement((1,0),"S").movement((-1,0),"N").movement((0,1),"E").movement((0,-1),"W").

% direction changes with turns
left("N","W").left("W","S").left("S","E").left("E","N").
right("N","E").right("E","S").right("S","W").right("W","N").