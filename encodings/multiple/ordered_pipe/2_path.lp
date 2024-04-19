%% generating ordered cyclefree paths

% move to enter the map
move(A,"Start",U) :- initialstate(A,U,_).
% move to leave the map
1 {move(A,(P,D),"End"): vertex((P,D))} 1 :- target(A,P,_).

% choice rule for moves, only one is needed
% every vertex may be left via up to une move
{move(A,U,V): edge(U,V)} 1 :- agent(A), vertex(U).
% every move may have a follow up move
% {move(A,U,V): edge(U,V)} 1 :- move(A,_,U).

% all moves except the start one, must have one before them
:- move(A,U,_), not move(A,_,U), U!="Start".
% all moves except the last one, must have one after them
:- move(A,_,V), not move(A,V,_), V!="End".

% every move has no more than 1 leading up to it
:- move(A,V,_), 2 {move(A,_,V)}.