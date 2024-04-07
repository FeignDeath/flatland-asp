# Installation
- suggested order for conda
- conda create env (python 3.11 as of now)
- install clingo via forge
- install numpy, matplotlib and pandas
- pip flatland

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

- auto checking via:
```
python testing/test-cornercases.py -e encodings/multiple/path/combined.lp -i testing/cornercases/instances/ -s testing/cornercases/solutions/ -t 100
```
- e is the path of the encoding
- i the path of the instances for testing
- s is the path of the solutions for the testing
- t is the maximum time allowed for computing every test

- this test is particularly difficult, since the encodings deliver different answer sets

# Testing flatland

- autogenerating maps and facts
```
python testing/flatland/generateinstances.py -n 10 -x 20 -y 24 -a 4
```
- n specifies the amount of maps generated
- x and y define the size of each map and require a minimum of 20x24
- a specifies the amount of trains for each map
- per default the script defaults 'testing/flatland/objects' as the directory for the flatland map objects and 'testing/flatland/facts' as the directory for the facts, both can be specified via -o and -f

- autotesting encodings for maps and facts
```
python testing/test-flatland.py -e encodings/multiple/path/combined.lp
```
- e specifies the encoding to be tested
- per default the script specifies 'testing/flatland/objects' as the directory for the flatland map objects and 'testing/flatland/facts' as the directory for the facts, both can be specified via -o and -f
- facts and objects need same structure within their folders
- unsat results might be unsolvable

## Benchmarking
- checks how many random instances can be solved in given time
```
python testing/benchmark-flatland.py -e encodings/multiple/grid/combined.lp
```
- e specifies the encoding to be tested
- x, y and a can be specified as arguments
- t sets timout