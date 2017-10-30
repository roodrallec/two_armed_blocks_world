% Main
clc; clear all;
%% Construct the problem domain from a parsed txt file
FILE_NAME = "problem1_input.txt";
domain = DomainParser(FILE_NAME);
%% Domain constants
ARMS = domain.getArms();
BLOCKS = domain.getBlocksMap();
MAX_COLS = domain.getMaxCols();
LIGHT_WEIGHT = 1;
WEAK_ARM = "L";
% Operators that can be applied to states
OPERATORS = buildOperators(ARMS, BLOCKS, MAX_COLS, WEAK_ARM, LIGHT_WEIGHT);
% Visualise an operator table
cell2table({ OPERATORS.name; OPERATORS.arm; OPERATORS.block1;...
    OPERATORS.block2; OPERATORS.cols;...
    OPERATORS.preConditions; OPERATORS.add; OPERATORS.del })
%% PLanner to build the path from stateA to stateB through goal regression
planner = Planner(OPERATORS);
%% Construct initial and final state
initialState = domain.getInitialState();
finalState = domain.getFinalState();
% Build the plan
disp("=== initial state===" + initialState.toString());
disp("=== final state===" + initialState.toString());
plan = planner.buildPlan(initialState, finalState);
%% Application of domain knowledge
% Domain knowledge is applied to prevent impossible operations not
% dealt by the regression algorithm.
% There are two ways that the domain knowledge can be applied:
% The first is buy preventing any impossible operators from being built
% this method is applied for rule 1, rule 2 in the buildOperators function.
% The second is by adding the necessary preconditions to the state so that
% the operator sees it as forbidden, this method is applied in the
% buildDomainPredicates function.

% Rule 1:
% An multi-block operator cannot operate on the same block
% e.g. STACK(L, A, A)
% This rule is implemented in the buildOperator function.

% Rule 2:
% The stacks of blocks is limited to 3
% This rule is implemented in the buildOperator function.

% Rule 3:
% The left arm can only lift blocks which are of 1kg
% Any blocks with 1kg have a predicate added to the state

% Rule 4:
% A block can only be placed on a block equal or heavier than itself
% Heavier predicates are added to the state
