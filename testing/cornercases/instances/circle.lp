% should work
% tests spawning and moving while meeting on a circle
% solution: action(0,2,1) action(1,2,3)

transition((1,0),("E","E")).transition((1,1),("E","E")).transition((1,2),("E","E")).transition((1,3),("E","E")).
transition((2,2),("N","N")).transition((1,2),("N","N")).transition((0,2),("N","W")).transition((0,1),("W","S")).transition((1,1),("S","E")).

initialstate(0,((1,0),"E"),1).target(0,(1,3),6).
initialstate(1,((2,2),"N"),2).target(1,(1,3),11).