% An encoding building upon the graph encoding. It solves the routing problem and the conflicts abstractly via an ordering, but timesteps are later on reintroduced to check for the goal.
%   - enforces personal horizons, swap and vertex conflicts

#include "0_input.lp".
#include "1_graph.lp".
#include "2_path.lp".
#include "3_conditions.lp".
#include "4_path.lp".
#include "5_output.lp".

#show starttime/2.
#show state/3.
#show left/2.
#show right/2.
#show edge/2.