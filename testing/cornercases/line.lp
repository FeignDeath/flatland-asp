% should work
% tests spawning an moving
% solution: action(0,1,2)

transition((0,0),("E","E")).transition((0,1),("E","E")).
initialstate(0,(0,0),1,"E").target(0,(0,1),4).