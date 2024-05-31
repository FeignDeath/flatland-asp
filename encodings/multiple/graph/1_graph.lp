%% representation of the graph

% vertices bundle possible cells together with the facing direction an agent may have when entering
vertex((P,D)) :- transition(P,(D,_)).

% edges bundle vertices to show that one may be reached from another
% due to lack of ideas of unification the graph is still directed
edge(((X,Y),D1),((X+X',Y+Y'),D2)) :- transition((X,Y),(D1,D2)), movement((X',Y'),D2), vertex(((X+X',Y+Y'),D2)).