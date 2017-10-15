% Main

clc; clear all;

% TODO: Function read Input.txt returns 4 vars as follows (once teachers provides correct file):
% https://moodle.urv.cat/moodle/mod/forum/discuss.php?d=371854#p683742

MaxColumns = 3;
Blocks = 'A*,B**,C**,D***,F*';
InitialState = 'ON-TABLE(C),ON(B,C),ON(A,B),CLEAR(A),ON-TABLE(D),ON(F,D),CLEAR(D),EMPTY-ARM(L),EMPTY-ARM(R)';
GoalState = 'ON-TABLE(B),ON(C,B),CLEAR(C),ON-TABLE(D),ON(A,D),ON(F,A),CLEAR(F),EMPTY-ARM(L),EMPTY-ARM(R)';

% Generate states
ei = state(InitialState, Blocks, MaxColumns);
ef = state(GoalState, Blocks, MaxColumns);

ei.print
ef.tostring

% Compare states
setdiff(ei.tostring, ef.tostring)

% Compare predicates (test)
pr1 = ei.predicates{5};
pref = ef.predicates{4};
pr1 == pref
isequal(pr1, pref)
cellfun(@(p) isequal(p , pref), ef.predicates) 

pr2 = ef.predicates([5,8]);

pr3 = [pr2, ei.predicates(1)];

ef.contains(pr3)
ef.ismember({pr1})

% 1) Given a State, find all previous moves
% 2) Find the previous moves possible

