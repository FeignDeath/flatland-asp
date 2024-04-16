import argparse
import json
import os
import shutil
import subprocess
import sys
import warnings
from flatland.envs.rail_env import RailEnv
from flatland.envs.rail_env import TrainState


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


def get_agents(agent):
    atoms = []

    # state(A,(X,Y),T,D)
    # A - agent handle
    # (X,Y) - position of the agent
    # T - time til earliest departure
    # D - direction "N", "E", "S" or "W"
    directions = {0:"\"N\"", 1:"\"E\"", 2:"\"S\"", 3:"\"W\""}
    initialstate = "initialstate(" + str(agent.handle) + ", (" + str(agent.initial_position) + ", " + str(directions[agent.direction]) + "), " + str(agent.earliest_departure) + ")"
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


def get_atoms(env,obs):
    # get atoms
    agent_handles = env.get_agent_handles()
    atoms = get_transitions(obs[agent_handles[0]])
    for i in agent_handles:
        atoms = atoms + get_agents(env.agents[i])

    # export atoms
    atoms.append("")
    output = ". ".join(atoms)

    return output


def run_clingo(input, encoding, timeout):
    limit = False
    name = encoding
    name = "tmp_" + name.replace("/","_") + ".lp"

    command = "clingo " + name + " " + encoding + " --outf=2 -W none | jq '.'"

    with open(name, "w") as file:
        file.write(input)

    # Run the command and capture its output
    try:
        output = subprocess.check_output(command, shell=True, timeout=timeout).decode('utf-8')
    except subprocess.TimeoutExpired:
        limit = True
    if limit: return "TIMEOUT", None, None, None

    os.remove(name)

    data = json.loads(output)
    if data["Result"] == "SATISFIABLE":
        return data["Result"], data["Time"]["Total"], data["Time"]["Solve"], data["Call"][-1]["Witnesses"][0]["Value"]
    else:
        return data["Result"], data["Time"]["Total"], data["Time"]["Solve"], None


def facts_to_flatland(atoms):
    dictionaries = {}

    # Iterate through the values
    for atom in atoms:
        parts = atom.split(",")
        x = int(parts[0].split("(")[1])
        a = int(parts[1])
        t = int(parts[2].strip(")\""))

        # Create a dictionary for x if it doesn't exist
        if x not in dictionaries:
            dictionaries[x] = {}

        # Add the corresponding d to the dictionary with t as the key
        dictionaries[x][t] = a

    return dictionaries


def run_orders(env, plan):
    t = 0

    while True:
        dictionary = {}
        for i in plan:
            if t in plan[i]: value = plan[i][t]
            else: value = 0
            dictionary[i] = int(value)
    
        obs, rew, done, info = env.step(dictionary)

        if done["__all__"]:
            return all(info["state"][i] == TrainState.DONE for i in info["state"])

        t += 1


def test(args):
    timeLeft = args.timeout
    l = len(str(timeLeft)) + 3
    sucess = 0
    failure = 0
    sumSolving = 0

    while True:

        print(f"Sucess: {sucess}, Failures: {failure}, Time left: {timeLeft:{l}.2f}", end="\r")

        warnings.filterwarnings("ignore")
        env = None
        env = RailEnv(width=args.width, height=args.height, number_of_agents=args.agents)
        obs = env.reset()

        initialAtoms = get_atoms(env, obs)
        sat, time, timeSolving, atoms = run_clingo(initialAtoms, args.encoding, timeLeft)

        if sat == "TIMEOUT": return sucess, failure, sumSolving/args.timeout
        if sat == "UNSATISFIABLE": failure += 1
        if sat == "SATISFIABLE":
            plan = facts_to_flatland(atoms)
            if run_orders(env, plan): sucess += 1
            else: failure += 1
            timeLeft = timeLeft - time
            sumSolving += timeSolving
        


def parse():
    parser = argparse.ArgumentParser(
        description="Test ASP encodings"
    )
    parser.add_argument('--encoding', '-e', metavar='<file>',
                        help='ASP encoding to test', required=True)
    parser.add_argument('--timeout', '-t', metavar='N', type=int,
                        help='Time for solving', default=600, required=False)
    parser.add_argument('--width', '-y', metavar='N', type=int,
                        help='Width of the flatland instances', default=40, required=False)
    parser.add_argument('--height', '-x', metavar='N', type=int,
                        help='Height of the flatland instances', default=40, required=False)
    parser.add_argument('--agents', '-a', metavar='N', type=int,
                        help='Amount of agents in the flatland instances', default=8, required=False)
    parser.add_argument('--clingo', '-c', metavar='<path>',
                        help='Clingo to use', default="clingo", required=False)
    args = parser.parse_args()

    if shutil.which(args.clingo) is None:
        raise IOError("file %s not found!" % args.clingo)
    if not os.path.isfile(args.encoding):
        raise IOError("file %s not found!" % args.encoding)
    if args.width < 20:
        raise IOError("width %s is less than 20!" % args.width)
    if args.height < 24:
        raise IOError("height %s is less than 24!" % args.height)
    if args.agents < 1:
        raise IOError("number of agents %s is less than 1!" % args.agents)

    return args


def main():
    if sys.version_info < (3, 5):
        raise SystemExit('Sorry, this code need Python 3.5 or higher')
    try:
        args=parse()
        sys.stdout.write("Running %sx%s:%s via %s for %d seconds \n" % (args.width, args.height, args.agents, args.encoding, args.timeout))
        s, f, sol = test(args)
        print(f"Sucess: {s}, Failures: {f}, Percentage of Solving Time: {sol*100:3.2f}")

    except Exception as e:
        sys.stderr.write("ERROR: %s\n" % str(e))
        return 1

if __name__ == '__main__':
    sys.exit(main())

