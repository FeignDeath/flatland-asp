%% generating timesteped paths through the graph

move(A,"Start",U) :- initialstate(A,U,_).
1{move(A,"End",(P,D)): vertex(P,D)} 1 :- target(A,P,_).