% spawning of the train
1 {starttime(A,T'): time(T'), T'>0, T'>=T, time(T'+2)} 1 :- initialstate(A,_,T).
state(A,V,T+1) :- initialstate(A,V,_), starttime(A,T).
state(A,V,T+2) :- initialstate(A,V,_), starttime(A,T).

% generating a move
{move(A,((P,D1),V,N,D2),T): weighted_edge((P,D1),V,N,D2), time(T+N)} 1 :- state(A,(P,D),T), not state(A,(P,D),T+1), not target(A,P,_).
% wait if no move
state(A,(P,D),T) :- not move(A,_,T-1), state(A,(P,D),T-1), time(T), not target(A,P,_).
% move if move
state(A,V,T+N) :- state(A,U,T), move(A,(U,V,N,D),T).

% #show state/3.
% #show move/3.