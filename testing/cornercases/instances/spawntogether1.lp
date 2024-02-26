% should work
% checks spawning and moving at the same place to the same target
% solution: action(0,3,2) action(1,1,2)

transition((0,0),("E","E")).transition((0,1),("E","E")).
initialstate(0,((0,0),"E"),1).target(0,(0,1),6).
initialstate(1,((0,0),"E"),1).target(1,(0,1),6).