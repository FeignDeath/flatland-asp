# a test like test-cornercases.py that instead of running cornercases runs run-orders on any pickle object in /flatland/objects/
# run orders will call get_orders, which uses for every pickle object the file named the same in /flatland/facts/

import argparse
import json
import os
import pickle
import shutil
import subprocess
import sys
import time
import warnings
import multiprocessing
from flatland.envs.rail_env import TrainState


# inputs are given as file names
def get_orders(input, encoding, timeout):
    # Define the command to run
    command = "clingo " + input + " " + encoding + " --outf=2 -W none | jq '.'"

    # Run the command and capture its output
    try:
        output_bytes = subprocess.check_output(command, shell=True, timeout=timeout)
        output = output_bytes.decode('utf-8')
        data = json.loads(output)
    except subprocess.CalledProcessError as e:
        print(f"Command failed with error: {e}")
        return None
    except json.JSONDecodeError as e:
        print(f"Failed to parse JSON: {e}")
        return None
    except subprocess.TimeoutExpired:
        # print(f"Command execution timed out.")
        return None

    if data is not None:
        if not data["Call"][-1].get("Witnesses",[]): return "unsat"
        # Extract the "Value" field
        values = data["Call"][-1]["Witnesses"][0]["Value"]

        # Initialize a dictionary to store the dictionaries
        dictionaries = {}

        # Iterate through the values
        for value in values:
            parts = value.split(",")
            x = int(parts[0].split("(")[1])
            a = int(parts[1])
            t = int(parts[2].strip(")\""))

            # Create a dictionary for x if it doesn't exist
            if x not in dictionaries:
                dictionaries[x] = {}

            # Add the corresponding d to the dictionary with t as the key
            dictionaries[x][t] = a

        return dictionaries

    return None


# run the orders
def run_orders(env, orders):
    t = 0

    while True:
        dictionary = {}
        for i in orders:
            if t in orders[i]: value = orders[i][t]
            else: value = 0
            dictionary[i] = int(value)
    
        obs, rew, done, info = env.step(dictionary)

        if done["__all__"]:
            return all(info["state"][i] == TrainState.DONE for i in info["state"])

        t += 1


def process_file(filepath, args):
    success = True
    print(filepath.replace(args.facts, ""), end="")
    start_time = time.time()
    orders = get_orders(filepath, args.encoding, args.timeout)
    end_time = time.time()
    
    if orders is None or orders == "unsat":
        if orders is None:
            print(" timeout")
            success = False
        else:
            print(" unsat  ")
        
    else:
        flatlandfile = filepath.replace(args.facts, args.objects)
        flatlandfile = flatlandfile.replace(".lp", ".pkl")
        with open(flatlandfile, "rb") as f:
            obj = pickle.load(f)
            warnings.filterwarnings("ignore")
            obj.reset()
            time_taken = (end_time - start_time) * 1000
            if run_orders(obj, orders):
                print(" success in " + str(time_taken)[:7] + " ms")
            else:
                success = False
                print(" failure in " + str(time_taken)[:7] + " ms")
    
    return success, time_taken


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

    success = all(success_list)
    average = sum(time_list) / len(time_list) if time_list else False

    return success, average


def parse():
    parser = argparse.ArgumentParser(
        description="Test ASP encodings"
    )
    parser.add_argument('--encoding', '-e', metavar='<file>',
                        help='ASP encoding to test', required=True)
    parser.add_argument('--timeout', '-t', metavar='N', type=int,
                        help='Time allocated to each instance (in seconds)', default=100, required=False)
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
    if not os.path.isfile(args.encoding):
        raise IOError("file %s not found!" % args.encoding)
    if not os.path.isdir(args.facts):
        raise IOError("directory %s not found!" % args.facts)
    if not os.path.isdir(args.objects):
        raise IOError("directory %s not found!" % args.objects)
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
    try:
        args=parse()
        success, average = test(args)
        if success:
            sys.stdout.write("SUCCESS\n")
        else:
            sys.stdout.write("FAILURE\n")
        if average:
            sys.stdout.write("Average time: " + str(average)[:7] + " ms (for satisfiable instances)\n")
    except Exception as e:
        sys.stderr.write("ERROR: %s\n" % str(e))
        return 1

if __name__ == '__main__':
    sys.exit(main())

