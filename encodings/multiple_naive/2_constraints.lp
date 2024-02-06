% none of the order constraints are needed since all of them are already implicitly realised through the modelling of the actions since none of the herein forbidden actions lead to a possible solution

% no order
% dissallowed if moving, multiple paths ahead and none is straight
:- not order(A,T,_), not transition((X+X',Y+Y'),(D,D)), 2 {transition((X+X',Y+Y'),(D,_))}, state(A,(X,Y),T,D,"True"),
    movement((X',Y'),D).

% order 1
% dissallowed if no left option
:- order(A,T,1), not transition((X+X',Y+Y'),(D1,D2)),
    state(A,(X,Y),T,D1,"True"), movement((X',Y'),D1), left(D1,D2).
% dissallowed at start
:- order(A,T,1), state(A,_,T,_,"Existent").
% dissallowed if only one path
:- order(A,T,1), 1 {transition((X+X',Y+Y'),_)} 1,
    state(A,(X,Y),T,D1,"True"), movement((X',Y'),D1), left(D1,D2).
:- order(A,T,1), 1 {transition((X,Y),(D,_))} 1,
    state(A,(X,Y),T,D,"False").

% order 2
% dissallowed if moving
:- order(A,T,2), state(A,_,T,_,"True").
% dissallowed if just spawned
:- order(A,T,2), state(A,_,T,_,"Existent").
% dissallowed if multiple paths and none is straight
:- order(A,T,2), not transition(P,(D,D)), 2 {transition(P,(D,_))},
    state(A,P,T,D,"False").

% order 3
% dissallowed if no right option
:- order(A,T,3), not transition((X+X',Y+Y'),(D1,D2)),
    state(A,(X,Y),T,D1,"True"), movement((X',Y'),D1), right(D1,D2).
% dissallowed at start
:- order(A,T,3), state(A,_,T,_,"Existent").
% dissallowed if only one path
:- order(A,T,3), 1 {transition((X+X',Y+Y'),_)} 1,
    state(A,(X,Y),T,D1,"True"), movement((X',Y'),D1), right(D1,D2).
:- order(A,T,3), 1 {transition((X,Y),(D,_))} 1,
    state(A,(X,Y),T,D,"False").

% order 4
% dissallowed if standing
:- order(A,T,4), state(A,_,T,_,"False").


% collision forbidance
:- T11==T22, state(A1,P,T1,_,_), speed(A1,S1), state(A2,P,T2,_,_), speed(A2,S2), A1!=A2, T1<=T11<T1+S1+2, T2<=T22<T2+S2+2, time(T11), time(T22).