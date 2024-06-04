#script (python)
import clingo

def contains(a, b):
    if str(b) in str(a):
        return clingo.Number(1)
    else:
        return clingo.Number(0)

#end.

step(1,"End").
step(A+1,step(A,S)):- step(A,S), A<2.

cont(S1,S2,@contains(S1,S2)) :- step(N1,S1), step(N2,S2).