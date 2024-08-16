This repository is a collection of tools and encodings used to extract and solve instances from [Flatland](https://www.aicrowd.com/challenges/flatland-3) using Clingo. This repository contains tools for:
- multiple encodings which solve a simple subdomain of flatland
- bulk generation of flatland instances and corresponding factfiles for Clingo
- bulk testing of encodings for generated instances
- automated generation and testing of corner cases for different encodings
- benchmarking tools, to evaluate different encodings, for different domains

Detailed explanations can be found in the folders.
- [encodings](encodings) contains encodings I implemented for this project
- [testing](testing) contains tools for testing, evaluation
- [example.ipynb](example.ipynb) is an example of what I did, what steps I took, and how Flatland works

# Installation
This is a suggested order, to set up the environment.
- conda create env (python 3.11 as of now)
- install clingo via forge
- install numpy, matplotlib and pandas
- pip flatland-rl
