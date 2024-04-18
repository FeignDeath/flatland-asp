import argparse
import csv
import json
import os
import shutil
import subprocess
import sys
import warnings
import psutil
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


def run_clingo(input, encoding, timeout, ram_limit):
    dirs = os.listdir(encoding)
    list.sort(dirs)
    dirs = [i for i in dirs if "step" in i]

    total_time = 0
    solve_time = 0
    output = input

    for i in dirs:
        print("\nho")
        command = "ulimit -v " + str(ram_limit*1024*1024*1024) + "; " + "echo \'" + input + "\' | clingo - " + encoding + i + " --outf=2 | jq"
        print(command)
        try:
            output = subprocess.check_output(command, shell=True, timeout=timeout, stderr=subprocess.DEVNULL).decode("utf-8")
        except subprocess.TimeoutExpired:
            return "TIMEOUT", None, None, None
        except subprocess.CalledProcessError:
            return "MEMORY", None, None, None

        try:
            data = json.loads(output)
        except json.JSONDecodeError:
            return "MEMORY", None, None, None

        if data["Result"] == "UNKNOWN":
            return "MEMORY", None, None, None
        if data["Result"] == "UNSATISFIABLE":
            return "UNSATISFIABLE", None, None, None
        
        total_time += data["Time"]["Total"]
        solve_time += data["Time"]["Solve"]
        output = data["Call"][-1]["Witnesses"][0]["Value"]
        input = output.copy()

        input.append("")
        input = ".".join(input)
        
    return "SATISFIABLE", total_time, solve_time, output


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
    ram_failure = 0
    sumSolving = 0
    consecutive_failures = 0

    while True:

        print(f"Sucess: {sucess}, Failures: {failure}, Time left: {timeLeft:{l}.2f}", end="\r")
        
        warnings.filterwarnings("ignore")
        env = None
        env = RailEnv(width=args.width, height=args.height, number_of_agents=args.agents)
        obs = env.reset()

        initialAtoms = get_atoms(env, obs)
        sat, time, timeSolving, atoms = run_clingo(initialAtoms, args.encoding, timeLeft, args.memory)

        if sat == "TIMEOUT": return sucess, failure, ram_failure, sumSolving
        if sat == "RAM FULL":
            ram_failure += 1
            failure += 1
            consecutive_failures += 1
        if sat == "UNSATISFIABLE":
            failure += 1
            consecutive_failures += 1
        if sat == "SATISFIABLE":
            plan = facts_to_flatland(atoms)
            if run_orders(env, plan):
                sucess += 1
                timeLeft = timeLeft - time
                sumSolving += timeSolving
                consecutive_failures = 0
            else:
                failure += 1
                consecutive_failures += 1

        if consecutive_failures > 2:
            return 0, 0, 0, 0


def parse():
    parser = argparse.ArgumentParser(
        description="Test ASP encodings"
    )
    parser.add_argument('--encoding', '-e', metavar='<dir>',
                        help='Path to the encodings which are piped from step1.lp to stepN.lp', required=True)
    parser.add_argument('--timeout', '-t', metavar='N', type=int,
                        help='Time for solving', default=600, required=False)
    parser.add_argument('--memory', '-m', metavar='N', type=int,
                        help='Maximum RAM allocated for solving in Gigabytes', default=8, required=False)
    parser.add_argument('--width', '-y', metavar='N', type=int,
                        help='Width of the flatland instances', default=40, required=False)
    parser.add_argument('--height', '-x', metavar='N', type=int,
                        help='Height of the flatland instances', default=40, required=False)
    parser.add_argument('--agents', '-a', metavar='N', type=int,
                        help='Amount of agents in the flatland instances', default=8, required=False)
    parser.add_argument('--clingo', '-c', metavar='<path>',
                        help='Clingo to use', default="clingo", required=False)
    parser.add_argument('--output', '-o', metavar='<file>',
                        help='CSV file to store the Benchmarking results in', default="log.csv", required=False)
    args = parser.parse_args()

    if shutil.which(args.clingo) is None:
        raise IOError("file %s not found!" % args.clingo)
    if not os.path.isdir(args.encoding):
        raise IOError("file %s not found!" % args.encoding)
    if args.width < 20:
        raise IOError("width %s is less than 20!" % args.width)
    if args.height < 24:
        raise IOError("height %s is less than 24!" % args.height)
    if args.agents < 1:
        raise IOError("number of agents %s is less than 1!" % args.agents)
    if args.memory*1024*1024*1024 > 0.8*psutil.virtual_memory().total:
        raise IOError(f"memory {args.memory}GB is more than 80 percent of the available memory {psutil.virtual_memory().total/1024/1024/1024:.0f}GB")
    if args.encoding[-1] != "/":
        args.encoding+="/"

    return args


def write_output(args, s, f, rf, sol):
    file_exists = os.path.exists(args.output)
    with open(args.output, "a", newline="") as csvfile:
        fieldnames = ["Encoding", "Height", "Width", "Trains", "Sucess", "Failures", "RAM_Failures", "Solving Time"]
        writer = csv.DictWriter(csvfile,fieldnames=fieldnames)

        if not file_exists:
            writer.writeheader()
        
        writer.writerow({
            "Encoding": args.encoding,
            "Height": args.height,
            "Width": args.width,
            "Trains": args.agents,
            "Sucess": s,
            "Failures": f,
            "RAM_Failures": rf,
            "Solving Time": sol
        })



def main():
    if sys.version_info < (3, 5):
        raise SystemExit('Sorry, this code need Python 3.5 or higher')
    try:
        args=parse()
        sys.stdout.write("Running %sx%s:%s via %s for %d seconds \n" % (args.width, args.height, args.agents, args.encoding, args.timeout))
        s, f, rf, sol = test(args)
        print(f"Sucess: {s}, Failures: {f}, Solving Time: {sol:.2f}")
        write_output(args, s, f, rf, sol)

    except Exception as e:
        sys.stderr.write("ERROR: %s\n" % str(e))
        return 1

if __name__ == '__main__':
    sys.exit(main())

