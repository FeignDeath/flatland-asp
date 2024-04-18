import subprocess
import json

def run(encoding1, encoding2, file):
    command1 = "clingo " + encoding1 + " " + file + " --outf=2 | jq"

    try:
        output = subprocess.check_output(command1, shell = True)
    except Exception as e:
        print(f"Error: {e}")
    
    result1 = json.loads(output)
    tmp = result1["Call"][0]["Witnesses"][0]["Value"]

    tmp.append("")

    tmp = ".".join(tmp)

    command2 = "echo \'" + tmp + "\' | clingo - " + encoding2 + " --outf=2 | jq"

    try:
        output = subprocess.check_output(command2, shell = True, stderr = subprocess.DEVNULL).decode("utf-8")
    except Exception as e:
        print(f"Error: {e}")
    print(output)

    result2 = json.loads(output)

    res = result2["Result"]
    total = result1["Time"]["Total"] + result2["Time"]["Total"]
    solve = result1["Time"]["Solve"] + result2["Time"]["Solve"]
    atoms = result2["Call"][0]["Witnesses"][0]["Value"]

    return res, total, solve, atoms
        

result = run("encodings/multiple/test/step1.lp", "encodings/multiple/test/step2.lp", "testing/cornercases/instances/line.lp")

print(result)