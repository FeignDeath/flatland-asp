% An encoding based upon the graph encoding. Unifies edges which are taken without decisions.
%   - only vertices left are, start, goal and vertices with multiple transitions
%   - may lack optimality due to this
%   - enforces personal horizons, swap and vertex conflicts

#include "0_input.lp".
#include "1_graph.lp".
#include "2_path.lp".
#include "3_conditions.lp".

#show starttime/2.
#show state/3.
#show initialstate/3.
#show move/3.
#show left/2.
#show right/2.
#show weighted_edge/4.