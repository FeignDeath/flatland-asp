# imports
# basic
import warnings
from flatland.envs.rail_env import RailEnv
# for running clingo
import os
import pickle
import argparse
import sys

# get global transitions
def get_transitions(obsx):
    transitions = obsx[0][0]
    x = 0
    atoms = []

    for i in transitions:
        y = 0
        for j in i:
            directions = ["(\"N\",\"N\")", "(\"N\",\"E\")", "(\"N\",\"S\")", "(\"N\",\"W\")", "(\"E\",\"N\")", "(\"E\",\"E\")", "(\"E\",\"S\")", "(\"E\",\"W\")", "(\"S\",\"N\")", "(\"S\",\"E\")", "(\"S\",\"S\")", "(\"S\",\"W\")", "(\"W\",\"N\")", "(\"W\",\"E\")", "(\"W\",\"S\")", "(\"W\",\"W\")"]
            usableDirections = [directions[i] for i, bit in enumerate(j) if bit == 1]

            for k in usableDirections:
                atoms.append(f"transition(({x},{y}),{k})")
            y += 1
        x += 1

    return atoms

# extract info of an agent
def get_agents(agent):
    atoms = []

    # state(A,(X,Y),T,D)
    # A - agent handle
    # (X,Y) - position of the agent
    # T - time til earliest departure
    # D - direction "N", "E", "S" or "W"
    directions = {0:"\"N\"", 1:"\"E\"", 2:"\"S\"", 3:"\"W\""}
    initialstate = "initialstate(" + str(agent.handle) + ", " + str(agent.initial_position) + ", " + str(agent.earliest_departure) + ", " + str(directions[agent.direction]) + ")"
    atoms.append(initialstate)

    # target(A,(X,Y),T)
    # A - agent handle
    # (X,Y) - position of the target
    # T - time til latest arrival
    target = "target(" + str(agent.handle) + ", "+str(agent.target) + ", " + str(agent.latest_arrival) + ")"
    atoms.append(target)

    # speed(A,S)
    # A - agent handle
    # S - steps taken for one transition
    speed = "speed(" + str(agent.handle) + ", " + str(agent.speed_counter.max_count+1) + ")"
    atoms.append(speed)

    return(atoms)

# get all atoms combined (agents and transitions)
def get_facts(env,obs,filename):
    # get atoms
    agent_handles = env.get_agent_handles()
    atoms = get_transitions(obs[agent_handles[0]])
    for i in agent_handles:
        atoms = atoms + get_agents(env.agents[i])

    # export atoms
    atoms.append("")
    output = ". ".join(atoms)
    with open(filename, "w") as file:
        file.write(output)

def parse():
    parser = argparse.ArgumentParser(
        description="Generate Flatland instances and corresponding sets if facts"
    )
    parser.add_argument('--number', '-n', metavar='N', type=int,
                        help='Number of encodings to generate', required=True)
    parser.add_argument('--width', '-x', metavar='N', type=int,
                        help='Width of the generated map (minimum 20x24)', required=True)
    parser.add_argument('--height', '-y', metavar='N', type=int,
                        help='Height of the generated map (minimum 20x24)', required=True)
    parser.add_argument('--agents', '-a', metavar='N', type=int,
                        help='Number of trains in the encoding', required=True)
    parser.add_argument('--objects', '-o', metavar='<path>',
                        help='Path of the flatland objects', default="testing/flatland/objects", required=False)
    parser.add_argument('--facts', '-f', metavar='<path>',
                        help='Path to store the sets of facts', default="testing/flatland/facts", required=False)
    args = parser.parse_args()
    if not os.path.isdir(args.objects):
        raise IOError("directory %s not found!" % args.objects)
    if not os.path.isdir(args.facts):
        raise IOError("directory %s not found!" % args.facts)
    if args.width < 20:
        raise IOError("width %s is less than 20!" % args.width)
    if args.height < 24:
        raise IOError("height %s is less than 24!" % args.height)
    if args.objects[-1] != "/":
        args.objects+="/"
    if args.facts[-1] != "/":
        args.facts+="/"
    return args

def main():
    if sys.version_info < (3, 5):
        raise SystemExit('Sorry, this code need Python 3.5 or higher')
    try:
        args=parse()
        
        dirname = str(args.width) + "x" + str(args.height) + "_" + str(args.agents) + "/"
        if not os.path.isdir(args.objects + dirname):
            os.mkdir(args.objects + dirname)
        if not os.path.isdir(args.facts + dirname):
            os.mkdir(args.facts + dirname)
        
        for i in range(0,args.number):
            warnings.filterwarnings("ignore")
            
            filename = "ex" + str(i)
            print("generating " + dirname + filename)
            env = RailEnv(width=args.width, height=args.height, number_of_agents=args.agents)
            with open(args.objects + dirname + filename + ".pkl", "wb") as file:
                pickle.dump(env, file)
            
            obs = env.reset()
            get_facts(env, obs, args.facts + dirname + filename + ".lp")
        
    except Exception as e:
        sys.stderr.write("ERROR: %s\n" % str(e))
        return 1

if __name__ == '__main__':
    sys.exit(main())
