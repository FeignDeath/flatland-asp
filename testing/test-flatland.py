# a test like test-cornercases.py that instead of running cornercases runs run-orders on any pickle object in /flatland/objects/
# run orders will call get_orders, which uses for every pickle object the file named the same in /flatland/facts/

import argparse
import json
import os
import pickle
import psutil
import shutil
import subprocess
import sys
import warnings
import multiprocessing
from flatland.envs.rail_env import TrainState

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
    while True:
        t = env._elapsed_steps

        dictionary = {}
        for i in plan:
            if t in plan[i]: value = plan[i][t]
            else: value = 0
            dictionary[i] = int(value)
    
        obs, rew, done, info = env.step(dictionary)

        if done["__all__"]:
            if all(info["state"][i] == TrainState.DONE for i in info["state"]) & sum(rew.values()) == 0:
                return True, t
            else:
                return False, t

        if t>1000:
            return False, t


def process_file(filepath, args):
    with open(filepath, "r") as file:
        input_data = file.read()

    success = True
    print(filepath.replace(args.facts, ""), end="")
    sat, t, st, atoms = run(input_data, args.encoding, args.timeout, args.memory)
    
    if sat == "UNSATISFIABLE":
        print(" unsat")
    if sat == "TIMEOUT":
        print(" timeout")
        success = False
    if sat == "MEMORY":
        print(" memory overflow")
        success = False
    if sat == "SATISFIABLE":
        flatlandfile = filepath.replace(args.facts, args.objects)
        flatlandfile = flatlandfile.replace(".lp", ".pkl")
        with open(flatlandfile, "rb") as f:
            obj = pickle.load(f)
            warnings.filterwarnings("ignore")
            obj.reset()
            orders = facts_to_flatland(atoms)
            state, steps = run_orders(obj, orders)
            if state:
                print(" success in " + str(t*1000)[:7] + " ms")
            else:
                success = False
                print(" failure in " + str(t*1000)[:7] + " ms")
    
    return success, t


def test(args):
    fileList = []
    for root, dirs, files in os.walk(args.facts):
        for file in files:
            fileList.append(os.path.join(root, file))
    fileList.sort()

    # Parallel processing
    pool = multiprocessing.Pool(processes=args.processes)
    results = [pool.apply_async(process_file, (filepath, args)) for filepath in fileList]
    pool.close()
    pool.join()

    success_list = [result.get()[0] for result in results]
    time_list = [result.get()[1] for result in results]
    time_list = [t for t in time_list if t!=None]

    success = all(success_list)
    average = sum(time_list) / len(time_list) if time_list else False

    return success, average


def parse():
    parser = argparse.ArgumentParser(
        description="Test ASP encodings"
    )
    parser.add_argument('--encoding', '-e', metavar='<dir>',
                        help='Path to the encodings which are piped from step1.lp to stepN.lp', required=True)
    parser.add_argument('--timeout', '-t', metavar='N', type=int,
                        help='Time allocated to each instance (in seconds)', default=100, required=False)
    parser.add_argument('--memory', '-m', metavar='N', type=int,
                        help='Maximum RAM allocated for solving in Gigabytes', default=8, required=False)
    parser.add_argument('--facts', '-f', metavar='<path>',
                        help='Directory of the facts', default="testing/flatland/facts/", required=False)
    parser.add_argument('--objects', '-s', metavar='<path>',
                        help='Directory of the flatland objects to solve on', default="testing/flatland/objects/", required=False)
    parser.add_argument('--clingo', '-c', metavar='<path>',
                        help='Clingo to use', default="clingo", required=False)
    parser.add_argument('--processes', '-p', metavar='N', type=int,
                        help='Amount of processes to use (parallelization)', default=1, required=False)
    args = parser.parse_args()
    if shutil.which(args.clingo) is None:
        raise IOError("file %s not found!" % args.clingo)
    if not os.path.isdir(args.encoding):
        raise IOError("file %s not found!" % args.encoding)
    if not os.path.isdir(args.facts):
        raise IOError("directory %s not found!" % args.facts)
    if not os.path.isdir(args.objects):
        raise IOError("directory %s not found!" % args.objects)
    if args.memory*1024*1024*1024 > 0.8*psutil.virtual_memory().total:
        raise IOError(f"memory {args.memory}GB is more than 80 percent of the available memory {psutil.virtual_memory().total/1024/1024/1024:.0f}GB")
    if args.processes > multiprocessing.cpu_count():
        raise IOError("Computer doesnt have %s cores, just %s found!" % (args.processes, multiprocessing.cpu_count()))
    if args.facts[-1] != "/":
        args.facts+="/"
    if args.objects[-1] != "/":
        args.objects+="/"
    return args

def main():
    if sys.version_info < (3, 5):
        raise SystemExit('Sorry, this code need Python 3.5 or higher')
    # try:
    args=parse()
    success, average = test(args)
    if success:
        sys.stdout.write("SUCCESS\n")
    else:
        sys.stdout.write("FAILURE\n")
    if average:
        sys.stdout.write("Average time: " + str(average*1000)[:7] + " ms (for satisfiable instances)\n")
    # except Exception as e:
    #     sys.stderr.write("ERROR: %s\n" % str(e))
    #     return 1

if __name__ == '__main__':
    sys.exit(main())

