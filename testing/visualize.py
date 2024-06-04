import json
import sys
from operator import itemgetter

def parse_state(state_str):
    """Parse the state string into components X, Y, D, and T."""
    parts = state_str.strip('state()').split(',')
    X, Y, direction, T = parts[0], parts[1].strip(')'), parts[2].strip('"').strip(')'), parts[3]
    return int(T), X, Y, direction

def main():
    # Read input from stdin
    input_data = json.load(sys.stdin)
    
    # Extract values from the input data
    values = input_data["Call"][0]["Witnesses"][0]["Value"]
    
    # Parse values into a list of tuples (T, X, Y, D)
    parsed_values = [parse_state(state) for state in values]
    
    # Sort the list by T
    sorted_values = sorted(parsed_values, key=itemgetter(0))
    
    # Print the chart
    print(f"{'T':>5} {'X':>5} {'Y':>5} {'D':>5}")
    print("-" * 20)
    for T, X, Y, D in sorted_values:
        print(f"{T:>5} {X:>5} {Y:>5} {D:>5}")

if __name__ == "__main__":
    main()