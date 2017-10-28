% Main
clc; clear all;

FILE_NAME = "problem1_input.txt";
worldDescription = WorldDescParser(FILE_NAME);

disp(worldDescription.getMaxCols());
disp(worldDescription.getBlocksMap());
disp(worldDescription.getInitialState());
disp(worldDescription.getFinalState());
% % Generate states
% ei = state(InitialState, Blocks, MaxColumns);
% ef = state(GoalState, Blocks, MaxColumns);
%
% result = solver(ei, ef);
%
%
%
% ei.print
% ef.tostring
%
% % Compare states
% setdiff(ei.tostring, ef.tostring)
%
% % Compare predicates (test)
% pr1 = ei.predicates{5};
% pref = ef.predicates{4};
% pr1 == pref
% isequal(pr1, pref)
% cellfun(@(p) isequal(p , pref), ef.predicates)
%
% pr2 = ef.predicates([5,8]);
%
% pr3 = [pr2, ei.predicates(1)];
%
% ef.contains(pr3)
% ef.ismember({pr1})
%
% % 1) Given a State, find all previous moves
% % 2) Find the previous moves possible
%
% % 'A*,B**,C**,D***,F*'
% % HEAVIER(D,C),HEAVIER(B,F),HEAVIER(D,B),HEAVIER(B,C),HEAVIER(C,B),HEAVIER(A,F),HEAVIER(F,A),HEAVIER(D,A),HEAVIER(C,A),HEAVIER(B,A)
%
% ei.predicates
