# two_armed_blocks_world
Blocks world solver using two arms in Matlab prototype.

## Instructions
Once the repository is cloned or the zip file extracted, you can run the
script from the terminal with the following command.
```
matlab main
```
From the Matlab interface, just place the working directory to the
repository or to the extracted folder and open the main.m script.
Click on the RUN button.

## Content description
Types of files:
- testingX: cases used for testing the algorithm
- benchmarkX: cases used for performance analysis
- main.m and loadconstant.m: scripts containing the code
- REDME.md: file containing this instructions

For each file type there are:
- {filetype}.txt: input file with the definition of the world 
(MaxColumns, Blocks, InitialState GoalState)
- output_{filetype}.txt: output file showing number of operators, number 
of states generated, the plan and the cancelled exploratory states
- output_{filetype}.log: verbose console output with all the steps evaluated
in each iteration
- {BenchmarkX}.png: plots generated in the performance analysis 
