% An encoding based on the graph encoding. The speed of pathgeneration is used to generate any set of paths.
%   - enforces swap and vertex conflicts
%   - no horizons at all, since reintroducing them would blow up the grounding
%   - fast to prove solvability of a problem if the horizon is ignored

#include "0_input.lp".
#include "1_graph.lp".
#include "2_path.lp".
#include "3_conflicts.lp".

#show move/3.
#show resolve/2.
#show initialstate/3.
#show time/1.
#show agent/1.
#show right/2.
#show left/2.
#show transition/2.