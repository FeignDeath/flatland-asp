initialstate(A,P,T,D) :- initialstate(A,(P,D),T).

% allowed timesteps limited by latest arrival time
time(T) :- T>=X : target(_,_,X); target(_,_,T).
time(T) :- time(T+1), T>=0.

% agents
agent(A) :- initialstate(A,_,_,_).

% available orders
order(1..4).

% directions after movement
movement((1,0),"S").movement((-1,0),"N").movement((0,1),"E").movement((0,-1),"W").

% direction changes with turns
left("N","W").left("W","S").left("S","E").left("E","N").
right("N","E").right("E","S").right("S","W").right("W","N").