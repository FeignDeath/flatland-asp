% should work

% first line
transition((0,0),("E","E")).transition((0,1),("E","E")).transition((0,2),("E","E")).transition((0,3),("E","E")).
% second line
transition((1,0),("E","E")).transition((1,1),("E","E")).transition((1,2),("E","E")).transition((1,3),("E","E")).
% switch
transition((0,2),("E","S")).transition((0,2),("N","E")).transition((1,2),("E","N")).transition((1,2),("S","E")).

% starting on the top line going to the bottom
initialstate(0,(0,0),1,"E").target(0,(1,3),9).
% starting on the bottom line goint to the top
initialstate(1,(1,0),1,"E").target(1,(0,3),9).