# Installation
- suggested order for conda
- conda create env (python 3.11 as of now)
- install clingo via forge
- install numpy, matplotlib and pandas
- pip flatland-rl

Goals:
- [Flatland Challenge](https://www.aicrowd.com/challenges/flatland-3)
- maps to facts
- facts to solutions
- verify solutions

# Testing corner cases
- corner cases as sets of facts for asp
- solutions for sets generated via following after asserting correctness:
```
for file in instances/*.lp; do
    base_name=$(basename "$file" .lp)
    clingo "$file" ../../encodings/multiple/path/combined.lp -n 0 --outf=2 > "solutions/${base_name}.json"
done
```

Auto checking via:
```
python testing/test-cornercases.py -e encodings/multiple/path/combined.lp -i testing/cornercases/instances/ -s testing/cornercases/solutions/ -t 100
```
- e is the path of the encoding
- i the path of the instances for testing
- s is the path of the solutions for the testing
- t is the maximum time allowed for computing every test

- this test is particularly difficult, since the encodings deliver different answer sets

# Testing flatland

Autogenerating maps and facts
```
python testing/flatland/generateinstances.py -n 10 -x 24 -y 24 -a 4
```
- n specifies the amount of maps generated
- x and y define the size of each map and require a minimum of 24x24
- c specifies the amount of cities on the map they can't be closed indefinetely close and so (x+y)/20 is used as the default
- a specifies the amount of trains for each map
- the script defaults 'testing/flatland/objects' as the directory for the flatland map objects and 'testing/flatland/facts' as the directory for the facts, both can be specified via -o and -f

Autotesting encodings for maps and facts
```
python testing/test-flatland.py -e encodings/multiple/grid/
```
- e specifies the encoding to be tested
- time and memory can be limited via -t and -m and are applied per instance
- p allows for parallelization and specifies how many processes are run parallel
- per default the script specifies 'testing/flatland/objects' as the directory for the flatland map objects and 'testing/flatland/facts' as the directory for the facts, both can be specified via -o and -f
- facts and objects need same structure within their folders
- unsat results might be unsolvable

## Benchmarking
- checks how many random instances can be solved in given time
```
python testing/benchmark-flatland.py -e encodings/multiple/grid/
```
- e specifies the directory of the encodings to be tested
    - encodings need to be in the form "stepn.lp"
    - step1.lp is solved and its output piped into step2.lp and so on
    - it also works with step1.py and so on, but requires, that they return an .json in similar fashion as clingo would and return clingo exit codes
- x and y define the size of each map and require a minimum of 24x24
- c specifies the amount of cities on the map they can't be closed indefinetely close and so (x+y)/20 is used as the default
- t sets timout
- m sets the ram limit
- o specifies a csv file to store results in
- f specifies at how many consecutive failures the benchmarking should stop

Benchmarking Suite
- runs the above multiple times
- checks whether output already exists
- runs instances with increased trains until either unsatisfiability, the time limit or the memory limit is hit
```
python testing/benchmark-suite.py -e encodings/multiple/grid/,encodings/multiple/incremental -s 50,100,200 -c 2,0,1000 -t 600
```
- e is a comma separated list of encodings in the above style
- s is a comma separated list of instance sizes to test (for example 50 for 50x50)
- c is a comma separated list of the number of cities to test (0 is interpreted as size/10, 1000 is to generate as many cities as possible to get dense instances)
- it tests all combinations of e,s and c and passes them together with the following flags to the benchmark-flatland.py
    - t sets timout
    - m sets the ram limit
    - o specifies a csv file to store results in
    - f specifies at how many consecutive failures the benchmarking should stop