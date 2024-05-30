import argparse
import csv
import os
import psutil
import shutil
import sys


# Checs whether the csv entrie already exists
def check_exists(file_path, encoding, size, cities, trains):
    if not os.path.exists(file_path):
        return False

    if cities < 2:
        cities = int(size/10)

    with open(file_path, mode="r") as file:
        reader = csv.DictReader(file)

        for row in reader:
            if (row['Encoding'] == encoding and 
                row['Height'] == str(size) and 
                row['Width'] == str(size) and 
                row['Cities'] == str(cities) and
                row['Trains'] == str(trains)):
                return True
    
    return False


def check_success(file_path, encoding, size, cities, trains):
    if not os.path.exists(file_path):
        return False
    
    if cities < 2:
        cities = int(size/10)

    with open(file_path, mode="r") as file:
        reader = csv.DictReader(file)

        for row in reader:
            if (row['Encoding'] == encoding and 
                row['Height'] == str(size) and 
                row['Width'] == str(size) and 
                row['Cities'] == str(cities) and
                row['Trains'] == str(trains) and
                row['Result'] == "SUCCESS"):
                return True
    
    return False


def test(args):
    for e in args.encodinglist:
        for s in args.sizelist:
            for c in args.citylist:
                check = True
                a = 5
                while(check):
                    if not check_exists(args.log, e, s, c, a):
                        command = f"python testing/benchmark-flatland.py -e {e} -x {s} -y {s} -c {c} -m {args.memory} -f {args.failures} -t {args.timeout} -a {a}"
                        if args.horizon:
                            command += " --horizon"
                        os.system(command)

                    if check_success(args.log, e, s, c, a):
                        a += 5
                    else:
                        check = False
    
    return True



def parse():
    parser = argparse.ArgumentParser(
        description="Test ASP encodings"
    )
    parser.add_argument('--encodinglist', '-e', metavar='N', type=str,
                        help='Comma separated list of encoding paths which are piped from step1.lp to stepN.lp', required=True)
    parser.add_argument('--timeout', '-t', metavar='N', type=int,
                        help='Time for solving', default=600, required=False)
    parser.add_argument('--memory', '-m', metavar='N', type=int,
                        help='Maximum RAM allocated for solving in Gigabytes', default=8, required=False)
    parser.add_argument('--sizelist', '-s', metavar='N', type=str,
                        help='Comma separated list of sizes used as width and height of the flatland instances', default="40", required=False)
    parser.add_argument('--citylist', '-c', metavar='N', type=str,
                        help='Comma separated list of number of starts and goals of the flatland instances', default="0", required=False)
    parser.add_argument('--clingo', '-cl', metavar='<path>',
                        help='Clingo to use', default="clingo", required=False)
    parser.add_argument('--log', '-l', metavar='<file>',
                        help='CSV file where the benchmarking results are stored', default="testing/log.csv", required=False)
    parser.add_argument('--horizon', '-ho', action=argparse.BooleanOptionalAction,
                        help='Sets whether a horizon should be used', required=False)
    parser.add_argument('--failures', '-f', metavar='N', type=int,
                        help='Amount of consecutive failures necessary to abort (Default=3)', default=3, required=False)
    args = parser.parse_args()

    if shutil.which(args.clingo) is None:
        raise IOError("file %s not found!" % args.clingo)

    for e in args.encodinglist.split(","):
        if not os.path.isdir(e):
            raise IOError("file %s not found!" % e)
    args.encodinglist = args.encodinglist.split(",")
    args.encodinglist = [encoding if encoding[-1] == "/" else encoding + "/" for encoding in args.encodinglist]

    for s in args.sizelist.split(","):
        if int(s) < 24:
            raise IOError("size %s is less than 24!" % args.width)
    args.sizelist = list(map(int, args.sizelist.split(",")))

    args.citylist = list(map(int, args.citylist.split(",")))

    if args.memory*1024*1024*1024 > 0.8*psutil.virtual_memory().total:
        raise IOError(f"memory {args.memory}GB is more than 80 percent of the available memory {psutil.virtual_memory().total/1024/1024/1024:.0f}GB")

    return args


def main():
    if sys.version_info < (3, 5):
        raise SystemExit('Sorry, this code need Python 3.5 or higher')
    try:
        args=parse()
        test(args)
        return 0

    except Exception as e:
        sys.stderr.write("ERROR: %s\n" % str(e))
        return 1

if __name__ == '__main__':
    sys.exit(main())