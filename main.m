% Main
clc; clear all;

FILE_NAME = "problem1_input.txt";
parser = DomainParser(FILE_NAME);
initialState = parser.getInitialState(); 
finalState = parser.getFinalState();
arms = parser.getArms(); 
blocks = parser.getBlocksMap(); 
maxCols = parser.getMaxCols();
lightWeight = 1;
weakArm = "L";
operators = buildOperators(arms, blocks, maxCols, weakArm);

%% Application of domain knowledge 
% Here domain knowledge is applied to prevent impossible operations not
% dealt by the regression algorithm.
% There are two ways that the domain knowledge can be applied:
% The first is buy preventing any impossible operators from being built
% this method is applied for rule 1, rule 2 in the buildOperators function.
% The second is by adding the necessary preconditions to the state so that
% the operator sees it as forbidden, this method is applied to rule3 

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
extraPredicates = [];
idx = 1;

for b1 = 1:length(blocks)    
    l1 = blocks(b1).label;
    w1 = blocks(b1).weight;
    
    if (w1 == lightWeight) 
        extraPredicates{idx} = Predicate("LIGHT-BLOCK", l1);
        idx = idx + 1;
    end
    
    for b2 = 1:length(blocks)
        
        if (b1 == b2)
            continue
        end        
        
        l2 = blocks(b2).label;        
        w2 = blocks(b2).weight;        
        
        if (w1 >= w2)
            extraPredicates{idx} = Predicate("HEAVIER", {l1, l2});
            idx = idx + 1;
        end
        
        if (w2 >= w1)
            extraPredicates{idx} = Predicate("HEAVIER", {l2, l1});
            idx = idx + 1;
        end        
    end
end
% The predicates are added to the initial and final states
extraPredicates = [extraPredicates{:}];
initialState.predicates = [initialState.predicates, extraPredicates];
finalState.predicates = [finalState.predicates, extraPredicates];
%% Planner run
planner = Planner(initialState, finalState);
plan = planner.buildPlan(operators);

