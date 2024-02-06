% % output needs to be swapped

% % startorder (not shifted)
outputaction(A,T,2) :- starttime(A,T).

% only first stop and shifted
outputaction(A,T-1,4) :- action(A,4,T), not action(A,4,T-1).

% only carry on if stopped before and shifted
outputaction(A,T-1,2) :- action(A,2,T), action(A,4,T-1).

% else shifted
outputaction(A,T-1,1) :- action(A,1,T).
outputaction(A,T-1,3) :- action(A,3,T).

#show outputaction/3.