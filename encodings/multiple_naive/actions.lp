% approach where the orders in flatland are modelled and used to reach the goal
    % this encoding does not care about deadends (since i never saw them) and might handle them incorrectly
    % this encoding implements speed, yet it asumes, that stopping and accalerating also depend on speed, yet as to that date such behavior has never been observed

% generating an order to spawn a train
1 {initialorder(A,T',2): T'>=T, T'>0, time(T')} 1 :- initialstate(A,P,T,D).
% generating at most one order per timestep if there is a state
0 {order(A,T,O): order(O)} 1 :- agent(A), time(T), state(A,_,T,_,_).


% calling the train into existence
% the state "Existent" is necessary to portrait it starting moving in the next time step if no orders are given
state(A,P,T+1,D,"Existent") :- initialstate(A,P,_,D), initialorder(A,T,2), time(T+1), T>=1.

% switch to normal states 
% magical acceleration of the train if no order is given
state(A,P,T+1,D,"True") :- not order(A,T,_), state(A,P,T,D,"Existent"), time(T+S), speed(A,S).
% or no movement if the train is told to stop
state(A,P,T+1,D,"False") :- order(A,T,4), state(A,P,T,D,"Existent"), time(T+1).

% behavior with no order
% no order and standing
state(A,P,T+1,D,"False") :- not order(A,T,_), state(A,P,T,D,"False"), time(T+1).
% no order and moving to a straight tile
state(A,(X+X',Y+Y'),T+1,D,"True") :- 
    not order(A,T,_), state(A,(X,Y),T,D,"True"), time(T+S), speed(A,S),
    transition((X,Y),(_,D)), movement((X',Y'),D), transition((X+X',Y+Y'),(D,D)).
% no order and only one way next
state(A,(X+X',Y+Y'),T+1,D2,"True") :-
    not order(A,T,_), state(A,(X,Y),T,D1,"True"), time(T+S), speed(A,S),
    transition((X,Y),(_,D1)), movement((X',Y'),D1), transition((X+X',Y+Y'),(D1,D2)), 1{transition((X+X',Y+Y'),(D1,_))}1.

% order 1 - left
% moving -> go left next
state(A,(X+X',Y+Y'),T+1,D2,"True") :- 
    order(A,T,1), state(A,(X,Y),T,D1,"True"), time(T+S), speed(A,S),
    transition((X,Y),(_,D1)), movement((X',Y'),D1), transition((X+X',Y+Y'),(D1,D2)), left(D1,D2), 2 {transition((X+X',Y+Y'),_)}.
% stopped -> accelerate left
state(A,P,T+1,D2,"True") :-
    order(A,T,1), state(A,P,T,D1,"False"), time(T+S), speed(A,S),
    transition(P,(D1,D2)), left(D1,D2), 2 {transition(P,_)}.

% order 2 - forward
% stopped and only one path -> accelerate along the path
state(A,P,T+1,D2,"True") :-
    order(A,T,2), state(A,P,T,D1,"False"), time(T+S), speed(A,S),
    1 {transition(P,(D1,_))} 1, transition(P,(D1,D2)).
% stopped and straight path -> accelerate straight
state(A,P,T+1,D,"True") :-
    order(A,T,2), state(A,P,T,D,"False"), time(T+S), speed(A,S),
    transition(P,(D,D)).

% order 3 - right
% moving -> go right next
state(A,(X+X',Y+Y'),T+1,D2,"True") :-
    order(A,T,3), state(A,(X,Y),T,D1,"True"), time(T+S), speed(A,S),
    transition((X,Y),(_,D1)), movement((X',Y'),D1), transition((X+X',Y+Y'),(D1,D2)), right(D1,D2), 2 {transition((X+X',Y+Y'),_)}.
% stopped -> accelerate right
state(A,P,T+1,D2,"True") :-
    order(A,T,3), state(A,P,T,D1,"False"), time(T+S), speed(A,S),
    transition(P,(D1,D2)), right(D1,D2), 2 {transition(P,_)}.

% order 4 - stop
% moving -> stop next with same direction
state(A,(X+X',Y+Y'),T+1,D,"False") :-
    order(A,T,4), state(A,(X,Y),T,D,"True"), time(T+S), speed(A,S), transition((X+X',Y+Y'),(D,_)),
    transition((X,Y),(_,D)), movement((X',Y'),D).