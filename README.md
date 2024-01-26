# flatland-asp

The solutions were generated via:
```
for file in instances/*.lp; do
    base_name=$(basename "$file" .lp)
    clingo "$file" ../../encodings/multiplePath+/ -n 0 --outf=2 > "solutions/${base_name}.json"
done
```

## testing cornercases

```
python testing/test.py -e encodings/multiplePath+/combined.lp -i testing/cornercases/instances/ -s testing/cornercases/solutions/ -t 100
```