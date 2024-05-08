%% generating ordered cyclefree paths

fromto(U,(P,D)) :- vertex((P,D)), initialstate(A,U,_), target(A,P,_).

% move to enter the map
1 {move(U,"Start",U): initialstate(_,U,_)} 1.
% move to leave the map
1 {move(U,V,"End"): fromto(U,V)} 1 :- move(U,"Start",U).

% choice rule for moves, only one is needed
% every vertex may be left via up to une move
% {move(A,U,V): edge(U,V)} 1 :- initialstate(_,A,_), vertex(U).
% every move may have a follow up move
{move(A,U,V): edge(U,V)} 1 :- move(A,_,U).

% all moves except the start one, must have one before them
:- move(A,U,_), not move(A,_,U), U!="Start".
% all moves except the last one, must have one after them
:- move(A,_,V), not move(A,V,_), V!="End".

% every move has no more than 1 leading up to it
:- move(A,V,_), 2 {move(A,_,V)}.

% add a bound for paths
:- N = {move(_,_,_)}, not time(N).

#show move/3.
#show initialstate/3.
#show time/1.
#show transition/2.
#show left/2.
#show right/2.
#show target/3.