% Main
clc; clear all;

FILE_NAME = "problem1_input.txt";
domain = DomainParser(FILE_NAME);
planner = Planner(domain.getInitialState(), domain.getFinalState());
operators = buildOperators(domain.getArms(), domain.getBlocksMap(), domain.getMaxCols());

% Here we apply our domain knowledge to remove impossible operations
% Rule 1:
% An operator can not operate on itself