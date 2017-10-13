% Main

clc; clear all;

% TODO: Function read Input.txt returns 4 vars as follows (once teachers provides correct file):
% https://moodle.urv.cat/moodle/mod/forum/discuss.php?d=371854#p683742

MaxColumns = 3;
Blocks = 'A*,B**,C**,D***,F*';
InitialState = 'ON-TABLE(C),ON(B,C),ON(A,B),CLEAR(A),ON-TABLE(D),ON(F,D),CLEAR(D),EMPTY-ARM(L),EMPTY-ARM(R)';
GoalState = 'ON-TABLE(B),ON(C,B),CLEAR(C),ON-TABLE(D),ON(A,D),ON(F,A),CLEAR(F),EMPTY-ARM(L),EMPTY-ARM(R)';

% Generate states
ei = state(InitialState, Blocks);
ef = state(GoalState, Blocks);

ei.print
ef.tostring

% Compare states
setdiff(ei.tostring, ef.tostring)
