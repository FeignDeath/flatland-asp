% should not work
% checks spawning and moving at the same place to the same target
% only works if collisions are ignored

transition((0,0),("E","E")).transition((0,1),("E","E")).
initialstate(0,(0,0),1,"E").target(0,(0,1),5).
initialstate(1,(0,0),1,"E").target(1,(0,1),5).