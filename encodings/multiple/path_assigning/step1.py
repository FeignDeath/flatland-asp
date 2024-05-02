import clingo
import json
import sys
import os

def local(file):
    script_dir = os.path.dirname(__file__)
    return os.path.join(script_dir, file)

def mod_symbols(symbols):
    output = []
    for i in range(len(symbols)):
        for symbol in symbols[i]:
            args = symbol.arguments
            if "move" in str(symbol):
                symbol = clingo.Function("move", [args[0], args[1], args[2], clingo.Number(i)])
            output.append(symbol)
    return output

def str_symbols(symbols):
    output = []
    for i in symbols:
        if isinstance(i, clingo.solving._SymbolSequence):
            for j in i:
                output.append(str(j))
        else:
            output.append(str(i))
    return output

def run(input_string):
    solutions = []

    def on_model(model):
        solutions.append(model.symbols(shown=True))

    ctl1 = clingo.Control(['--stats'])
    ctl1.add("base", [], input_string)
    ctl1.load(local("0_input.lp"))
    ctl1.load(local("1_graph.lp"))
    ctl1.load(local("2_path.lp"))

    ctl1.ground([("base", [])])
    ctl1.configuration.solve.models = 0

    r = ctl1.solve(on_model=on_model)
    if str(r) == "UNSAT":
        sys.exit(20)

    times = ctl1.statistics["summary"]["times"]

    symbols = mod_symbols(solutions)
    strings = str_symbols(symbols)

    base = ".".join(strings) + "."

    ctl2 = clingo.Control(['--stats'])
    ctl2.add("base", [], base)
    ctl2.load(local("3_conflicts.lp"))
    ctl2.load(local("4_path.lp"))
    ctl2.load(local("5_output.lp"))

    ctl2.ground([("base", [])])
    solutions = []
    ctl2.solve(on_model=on_model)

    new_times = ctl2.statistics["summary"]["times"]
    times = {k: times.get(k, 0) + new_times.get(k, 0) for k in set(times)}

    # Capitalize keys in times dictionary
    capitalized_times = {key.capitalize(): value for key, value in times.items()}

    # Create JSON output structure
    json_output = {
        "Time": capitalized_times,
        "Call": [
            {
                "Witnesses": [
                    {
                        "Value": str_symbols(solutions)
                    }
                ]
            }
        ]
    }

    return json_output

def main():
    input_string = sys.stdin.read()

    result = run(input_string)

    print(json.dumps(result))

if __name__ == "__main__":
    main()