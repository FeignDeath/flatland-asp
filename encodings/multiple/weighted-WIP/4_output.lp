% output needs to be swapped

% startorder (not shifted)
outputaction(A,T,2) :- starttime(A,T).

% first stop to hinder auto accelerating
outputaction(A,T,4) :- not state(A,_,T-1), state(A,V,T), state(A,V,T+2).

% only first stop and shifted
outputaction(A,T,4) :- state(A,V,T+1), state(A,V,T+2), not state(A,V,T), state(A,_,T).

% only carry on if stopped before and shifted
outputaction(A,T,2) :- state(A,V,T), state(A,V,T+1), not state(A,V,T+2),
    not outputaction(A,T,1), not outputaction(A,T,3),  % left and right turn have same effect and duplicate orders are forbidden
    not outputaction(A,T-1,2), % only possible via the spawning of train, prevents generation of unnecessary order
    state(A,_,T+2). % no order necessary if stopped state is the goal state

% left or right if necessary change
outputaction(A,T,1) :- state(A,(P1,D1),T+1), state(A,(_,D2),T+2), left(D1,D2), 2 {edge((P1,D1),_)}.
outputaction(A,T,3) :- state(A,(P1,D1),T+1), state(A,(_,D2),T+2), right(D1,D2), 2 {edge((P1,D1),_)}.

#show outputaction/3.