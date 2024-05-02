% should work
% tests spawning an moving
% solution: action(0,2,1)

transition((0,0),("E","E")).transition((0,1),("E","E")).transition((0,2),("E","E")).
transition((0,1),("E","S")).transition((1,1),("S","E")).transition((1,2),("E","N")).transition((0,2),("N","E")).
initialstate(0,((0,0),"E"),1).target(0,(0,2),5).