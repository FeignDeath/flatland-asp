This directory collects encodings, which implement different approaches to solving Flatland instances.

The different encodings are split into subdirectories. They consist of multiple steps which need to be piped. The first step also contains a short description.

They all fulfill the following requirements. Other encodings need to fulfill them as well, to be used by the testing tools provided by [testing](../testing).

# Requirements

## Inputs

- transition((X,Y),(EnteringDirection,LeavingDirection)) - representing the map
- initialstate(Agent,((X,Y),FacingDirection),EarliestDeparture) - representing the starts
- target(Agent,(X,Y),LatestArrival) - representing goals and individual horizons

## Outputs

- outputaction(Agent,Time,Action) - which represents what agent does what when
    - valid actions are
        - 0 no action
        - 1 turn left
        - 2 continue
        - 3 turn right
        - 4 stop

## Corncer Cases of Flatland

- execution of actions is delayed by one timestep
- first action 2 has no other effect than spawning the train
- spawned trains start moving automatically if no other actions are given
- grid is aligned (0,0) is in top left, (1,0) is to the south, (0,1) is to the east
- goals are not always reachable on time as the calculation for the timetable ignores conflicts
- the flatland visualizer sometimes misrepresents the map (earlier spawning and de-spawning)

## Encoding Formatting

In order for an encoding it needs to follow the following format:
- the tools uses directory names instead of direct encodings
- a valid directory needs at least one encoding named stepX.lp or step.lp
- multiple steps are run sequentially, with the outputs being used as input for the next step
- steps are run from step1 to step9