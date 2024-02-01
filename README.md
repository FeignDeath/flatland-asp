This repository has the goal of converting maps from the [Flatland Challenge](https://www.aicrowd.com/challenges/flatland-3) into sets of facts. Those sets are then solved via ASP, specifically Clingo and later on reimported into flatland and checked for workability.

# Testing corner cases
To check the basic functionality of the encoding I wrote some test cases, the encoding needs to pass or fail according to the requirements. After checking manually, whether the results are the expected ones for of my encodings and used it to generate the solutions via the following bash script:

```
for file in instances/*.lp; do
    base_name=$(basename "$file" .lp)
    clingo "$file" ../../encodings/multiplePath+/ -n 0 --outf=2 > "solutions/${base_name}.json"
done
```

A new encoding can be checked automatically by running the following python script at the root of this repository. At the moment the encoding still generates a failure if one of the instances fails to be satisfied, yet that is the expected behavior, as the instance is supposed to be unsatisfieable, by an encoding which checks collision conflicts.

```
python testing/test.py -e encodings/multiplePath+/combined.lp -i testing/cornercases/instances/ -s testing/cornercases/solutions/ -t 100
```
- e is the path of the encoding
- i the path of the instances for testing
- s is the path of the solutions for the testing
- t is the maximum time allowed for computing every test

# Testing flatland

Testing on multiple flatland maps is automated into two steps. At first a python script generates a set of flatland maps, saved as .pkl files with corresponding sets of facts for clingo split into two folders. This python script generates a new folder, in the facts and objects folder named like the width, height, and number of trains. 
```
python testing/flatland/generateinstances.py -n 10 -x 20 -y 24 -a 4
```
- n specifies the amount of maps generated
- x and y define the size of each map and require a minimum of 20x24
- a specifies the amount of trains for each map
- per default the script defaults 'testing/flatland/objects' as the directory for the flatland map objects and 'testing/flatland/facts' as the directory for the facts, both can be specified via -o and -f

Secondly an encoding can be tested automatically for every pair of objects and facts, via another python script. For the script to work, it's necessary, that every pair of object and facts is stored in the exact same data structure within their corresponding folders.
```
python testing/test-flatland.py -e encodings/multipleActions/combined.lp
```
- e specifies the encoding to be tested
- per default the script specifies 'testing/flatland/objects' as the directory for the flatland map objects and 'testing/flatland/facts' as the directory for the facts, both can be specified via -o and -f