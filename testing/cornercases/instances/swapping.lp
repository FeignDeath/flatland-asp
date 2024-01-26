% should not work
% checks whether trains are able to swap

transition((0,0),("E","E")).transition((0,1),("E","E")).
transition((0,0),("W","W")).transition((0,1),("W","W")).
initialstate(0,(0,0),1,"E").target(0,(0,1),4).
initialstate(1,(0,1),1,"W").target(1,(0,0),4).
