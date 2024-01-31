% output needs to be swapped

% startorder (not shifted)
outputaction(A,T,2) :- starttime(A,T).

% first stop to hinder auto accelerating
outputaction(A,T-1,4) :- not state(A,_,T-2,_), state(A,P,T-1,_), state(A,P,T+1,_).

% only first stop and shifted
outputaction(A,T-1,4) :- not state(A,P,T-1,_), state(A,P,T,_), state(A,P,T+1,_), state(A,_,T-1,_).

% only carry on if stopped before and shifted
outputaction(A,T-1,2) :- state(A,P,T-1,_), state(A,P,T,_), not state(A,P,T+1,_), not outputaction(A,T-1,1), not outputaction(A,T-1,3), state(A,_,T+1,_).

% left or right if necessary change
outputaction(A,T-1,1) :- state(A,P,T,D1), state(A,_,T+1,D2), left(D1,D2), 2 {transition(P,(D1,_))}.
outputaction(A,T-1,3) :- state(A,P,T,D1), state(A,_,T+1,D2), right(D1,D2), 2 {transition(P,(D1,_))}.

% #show target/3.
% #show pos(B,C) : state(A,B,C,_), A=3.
% #show act(B,C) : outputaction(A,B,C), A=3.
% #show.
% #show state/4.
#show outputaction/3.