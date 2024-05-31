% An encoding based upon the graph encoding. Unifies edges which are taken without decisions.
%   - only vertices left are, start, goal and vertices with multiple transitions
%   - may lack optimality due to this
%   - enforces personal horizons, swap and vertex conflicts

#include "0_input.lp".
#include "1_graph.lp".
#include "2_path.lp".
#include "3_conditions.lp".
#include "4_output.lp".