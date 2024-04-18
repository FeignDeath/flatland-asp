% % the goal must be reached in time
% goal(A) :- state(A,"End",_).

% % goal(A) :- state(A,(P,_),T'), T'<=T, target(A,P,T).
% :- agent(A), not goal(A).