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
from flatland.envs.rail_generators import sparse_rail_generator


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


def limit_memory(ram_limit):
    # Define a function to set resource limits
    import resource
    def set_limits():
        resource.setrlimit(resource.RLIMIT_AS, (ram_limit*1024**3, ram_limit*1024**3))
    return set_limits


def run_clingo(input_data, encoding, timeout, ram_limit):
    command = ["clingo", "-", encoding, "--outf=2"]

    try:
        output = subprocess.check_output(
            command,
            timeout=timeout,
            stderr=subprocess.DEVNULL,
            input=input_data.encode("utf-8"),
            preexec_fn=limit_memory(ram_limit)).decode("utf-8")

    except subprocess.TimeoutExpired:
        return "TIMEOUT"
    except subprocess.CalledProcessError as e:
        # This is no Error this is the normal way clingo exits
        # Whoever made this should be stoned

        # But it also embodies errors, so here is the memory one:
        if e.returncode == 33:
            return "MEMORY"
        if e.returncode == 20:
            return "UNSATISFIABLE"

        # And here is the output to make it work
        return e.output


def run_python(input_data, program, timeout, ram_limit):
    command = ["python", program]

    try:
        output = subprocess.check_output(
            command,
            timeout=timeout,
            stderr=subprocess.DEVNULL,
            input=input_data.encode("utf-8"),
            preexec_fn=limit_memory(ram_limit)).decode("utf-8")

    except subprocess.TimeoutExpired:
        return "TIMEOUT"
    except subprocess.CalledProcessError as e:
        if e.returncode == 20:
            return "UNSATISFIABLE"
        else:
            return "MEMORY"
    except Exception as e:
        print(f"Problem with Python {e=}, {type(e)=}")
        raise

    return output.encode("utf-8")


def run(input_data, encoding, timeout, ram_limit):
    dirs = os.listdir(encoding)
    list.sort(dirs)
    dirs = [i for i in dirs if "step" in i]

    total_time = 0
    solve_time = 0
    output_atoms = input_data

    for i in dirs:
        if ".lp" in i:
            output = run_clingo(input_data, encoding + i, timeout, ram_limit)
            if (output == "TIMEOUT") | (output == "MEMORY") | (output == "UNSATISFIABLE"):
                return output, None, None, None
        if ".py" in i:
            output = run_python(input_data, encoding + i, timeout, ram_limit)
            if (output == "TIMEOUT") | (output == "MEMORY") | (output == "UNSATISFIABLE"):
                return output, None, None, None

        jq_output = subprocess.check_output(["jq"], input=output)
        data = json.loads(jq_output)

        total_time += data["Time"]["Total"]
        solve_time += data["Time"]["Solve"]
        output_atoms = data["Call"][-1]["Witnesses"][0]["Value"]
        input_data = output_atoms.copy()

        input_data.append("")
        input_data = ".".join(input_data)
        
    return "SATISFIABLE", total_time, solve_time, output_atoms


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

        t += 1

        if done["__all__"]:
            return all(info["state"][i] == TrainState.DONE for i in info["state"]), t
        
        if t > 1000:
            return False, t



def test(args):
    timeLeft = args.timeout
    l = len(str(timeLeft)) + 3
    success = 0
    failure = 0
    ram_failure = 0
    sum_solving = 0
    consecutive_failures = 0
    accumulated_horizon = 0
    failure_reasons = []
    given_horizon = 0

    while True:

        print(f"Success: {success}, Failures: {failure}, Time left: {timeLeft:{l}.2f}", end="\r")
        
        warnings.filterwarnings("ignore")
        env = None
        env = RailEnv(width=args.width, height=args.height, number_of_agents=args.agents, rail_generator=sparse_rail_generator(max_num_cities=args.cities))
        obs = env.reset()
        horizon = env._max_episode_steps
        if not args.horizon: env._max_episode_steps = None

        initialAtoms = get_atoms(env, obs)
        sat, time, timeSolving, atoms = run(initialAtoms, args.encoding, timeLeft, args.memory)

        if sat == "TIMEOUT":
            if success != 0:
                return "SUCCESS", success, failure, failure_reasons, sum_solving/(args.timeout-timeLeft), int(given_horizon/success), int(accumulated_horizon/success)
            else:
                failure_reasons.append("TIMEOUT")
                return "FAILURE", success, failure, failure_reasons, 0, 0, 0
        if sat == "SATISFIABLE":
            plan = facts_to_flatland(atoms)
            state, steps = run_orders(env,plan)
            if state:
                success += 1
                timeLeft = timeLeft - time
                sum_solving += timeSolving
                consecutive_failures = 0
                given_horizon += horizon
                accumulated_horizon += steps
            else:
                failure += 1
                consecutive_failures += 1
                failure_reasons.append("PLAN_ERROR")
        else:
            failure += 1
            consecutive_failures += 1
            failure_reasons.append(sat)

        if consecutive_failures == args.failures:
            return "FAILURE", success, failure, failure_reasons, 0, 0, 0


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
    parser.add_argument('--cities', '-c', metavar='N', type=int,
                        help='Number of starts and goals', default=0, required=False)
    parser.add_argument('--agents', '-a', metavar='N', type=int,
                        help='Amount of agents in the flatland instances', default=8, required=False)
    parser.add_argument('--clingo', '-cl', metavar='<path>',
                        help='Clingo to use', default="clingo", required=False)
    parser.add_argument('--output', '-o', metavar='<file>',
                        help='CSV file to store the Benchmarking results in', default="testing/log.csv", required=False)
    parser.add_argument('--horizon', '-ho', action=argparse.BooleanOptionalAction,
                        help='Sets whether a horizon should be used', required=False)
    parser.add_argument('--failures', '-f', metavar='N', type=int,
                        help='Amount of consecutive failures necessary to abort (Default=3)', default=3, required=False)
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
    if args.cities < 2:
        args.cities = int((args.width+args.height)/20)

    return args


def write_output(args, r, s, f, df, sol, gh, h):
    file_exists = os.path.exists(args.output)

    output_df = ""
    for i in df:
        output_df += i + ":"
    df = output_df[0:-1]


    with open(args.output, "a", newline="") as csvfile:
        fieldnames = ["Encoding", "Height", "Width", "Cities", "Trains", "Result", "Success", "Failures", "Detailed Failures", "Solving Proportion", "Given Horizon", "Resulting Horizon"]
        writer = csv.DictWriter(csvfile,fieldnames=fieldnames)

        if not file_exists:
            writer.writeheader()
        
        writer.writerow({
            "Encoding": args.encoding,
            "Height": args.height,
            "Width": args.width,
            "Cities": args.cities,
            "Trains": args.agents,
            "Result": r,
            "Success": s,
            "Failures": f,
            "Detailed Failures": df,
            "Solving Proportion": sol,
            "Given Horizon": gh,
            "Resulting Horizon": h
        })


def main():
    if sys.version_info < (3, 5):
        raise SystemExit('Sorry, this code need Python 3.5 or higher')
    try:
        args=parse()
        sys.stdout.write("Running %sx%s:%s_%s via %s for %d seconds \n" % (args.width, args.height, args.cities, args.agents, args.encoding, args.timeout))
        r, s, f, df, sol, gh, h = test(args)
        print()
        write_output(args, r, s, f, df, sol, gh, h)

    except Exception as e:
        sys.stderr.write("ERROR: %s\n" % str(e))
        return 1

if __name__ == '__main__':
    sys.exit(main())

