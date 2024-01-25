% specifies how to generate a patspecifies how to generate a path

% generate first steps
    % state(Agent,Position,Timestep,DirectionOfLeaving)
    % rewriteworthy to portrait ability to stand longer at the start and change the direction
state(A,P,T+2,D) :- initialstate(A,P,T,D), T>0.
state(A,P,3,D) :- initialstate(A,P,T,D), T=0.

% generate next steps until the goal or the horizon is reached
1 {state(A,(X+X',Y+Y'),T1+1,D2) : movement((X',Y'),D1), transition((X+X',Y+Y'),(D1,D2))} 1 :- state(A,(X,Y),T1,D1), not target(A,(X,Y),_), time(T1+1).

