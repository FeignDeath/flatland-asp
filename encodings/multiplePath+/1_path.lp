% specifies how to generate a patspecifies how to generate a path

% generate first steps
    % state(Agent,Position,TimeOfEntering,TimeOfLeaving,DirectionOfEntering,DirectionOfLeaving)


1 {starttime(A,T'): time(T'), T'>0, T'>=T, time(T'+2)} 1 :- initialstate(A,_,T,_).
state(A,P,T+1,T+2,D,D) :- initialstate(A,P,_,D), starttime(A,T).

% generate next steps until the goal or the horizon is reached
1 {state(A,(X+X',Y+Y'),T1+1,T2,D1,D2) : time(T2), T2>T1, movement((X',Y'),D1), transition((X+X',Y+Y'),(D1,D2))} 1 :- state(A,(X,Y),_,T1,_,D1), not target(A,(X,Y),_), time(T1+1).
