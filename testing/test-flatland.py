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
from flatland.envs.rail_env import TrainState

# inputs are given as file names
def get_orders(input, encoding,timeout):
    # Define the command to run
    command = "clingo " + input + " " + encoding + " --outf=2 | jq '.'"

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
        if not data["Call"][0].get("Witnesses",[]): return "unsat"
        # Extract the "Value" field
        values = data["Call"][0]["Witnesses"][0]["Value"]

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

def test(args):
    success = True
    fileList = []
    timeList = []
    for root, dirs, files in os.walk(args.facts):
        for file in files:
            fileList.append(os.path.join(root, file))
    fileList.sort()
    for filepath in fileList:
        print(filepath.replace(args.facts, ""), end="")
        start_time = time.time()
        orders = get_orders(filepath, args.encoding, args.timeout)
        end_time = time.time()
        
        if orders == None or orders == "unsat":
            if orders == None:
                print(" timeout")
                success = False
            else:
                print(" unsat  ")
            
        else:
            flatlandfile = filepath.replace(args.facts, args.objects)
            flatlandfile = flatlandfile.replace(".lp", ".pkl")
            with open(flatlandfile, "rb") as f:
                object = pickle.load(f)
                warnings.filterwarnings("ignore")
                object.reset()
                timeTaken = (end_time-start_time)*1000
                timeList.append(timeTaken)
                if run_orders(object, orders):
                    print(" success in " + str(timeTaken)[:7] + " ms")
                else:
                    success = False
                    print(" failure in " + str(timeTaken)[:7] + " ms")

    if len(timeList) != 0:
        average = sum(timeList) / len(timeList)
    else:
        average = False

    return success, average


def parse():
    parser = argparse.ArgumentParser(
        description="Test ASP encodings"
    )
    parser.add_argument('--encoding', '-e', metavar='<file>',
                        help='ASP encoding to test', required=True)
    parser.add_argument('--timeout', '-t', metavar='N', type=int,
                        help='Time allocated to each instance', default=100, required=False)
    parser.add_argument('--facts', '-f', metavar='<path>',
                        help='Directory of the facts', default="testing/flatland/facts/", required=False)
    parser.add_argument('--objects', '-s', metavar='<path>',
                        help='Directory of the flatland objects to solve on', default="testing/flatland/objects/", required=False)
    parser.add_argument('--clingo', '-c', metavar='<path>',
                        help='Clingo to use', default="clingo", required=False)
    args = parser.parse_args()
    if shutil.which(args.clingo) is None:
        raise IOError("file %s not found!" % args.clingo)
    if not os.path.isfile(args.encoding):
        raise IOError("file %s not found!" % args.encoding)
    if not os.path.isdir(args.facts):
        raise IOError("directory %s not found!" % args.facts)
    if not os.path.isdir(args.objects):
        raise IOError("directory %s not found!" % args.objects)
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

