%% step(identifier,stepnumber,position), identifier is start + number

% detects whether string contains a substring to check whether a cell has been passed
#script (python)
import clingo

def contains(a, b):
    # checks whether a contains b
    if str(b) in str(a):
        return clingo.Number(1)
    else:
        return clingo.Number(0)

#end.

% generate all possible steps, with all steps taken before
step(U,0,U,"Start") :- initialstate(_,U,_).
step(U,N+1,W,step(U,N,V,S)) :- step(U,N,V,S), edge(V,W), time(N+1), @contains(S,V)!=1.

% select all valid paths
path((U,G,step(U,N,V,S)),N) :- step(U,N,V,S), initialstate(A,U,_), target(A,G,_), V=(G,_).

% generate all steps for those paths
pathSteps((U,G,S), S) :- path((U,G,S),_).
pathSteps(I,S) :- pathSteps(I, step(U,N,V,S)).

% reformat steps for next encoding
path(I,N,V) :- pathSteps(I, step(_,N,V,_)).