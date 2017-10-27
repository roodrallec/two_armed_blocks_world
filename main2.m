%% Read Input
clc, clear all;
% TODO: Function read Input.txt returns 4 vars as follows (once teachers provides correct file):
% https://moodle.urv.cat/moodle/mod/forum/discuss.php?d=371854#p683742
% https://www.youtube.com/watch?v=yOunULLOxu0

MaxColumns = 3;
%Blocks = 'A*,B**,C**,D***,F*';
%InitialState = 'ON-TABLE(C),ON(B,C),ON(A,B),CLEAR(A),ON-TABLE(D),ON(F,D),CLEAR(D),EMPTY-ARM(L),EMPTY-ARM(R)';
%GoalState = 'ON-TABLE(B),ON(C,B),CLEAR(C),ON-TABLE(D),ON(A,D),ON(F,A),CLEAR(F),EMPTY-ARM(L),EMPTY-ARM(R)';

Blocks = 'A*,B*,C*';
InitialState = 'ON-TABLE(C),ON-TABLE(A),ON(B,A),CLEAR(B),CLEAR(C),EMPTY-ARM(L),EMPTY-ARM(R)';
GoalState = 'ON-TABLE(C),ON(B,C),ON(A,B),CLEAR(A),EMPTY-ARM(L),EMPTY-ARM(R)';

%% Main
loadconstants

% Parse blocks
blockWeight = parseBlocks(Blocks);
isheavier(blockWeight,'A','B')

ei = parseState(InitialState);
ef = parseState(GoalState);

ei(3)
[n, a] = decompose(ei(3));
compose(n,a)

%[pre, add, del] = action("STACK", ["A", "B"]);
% Adding HEAVIER, LIGHT-BLOCK, USE-COLS-NUM?

%% Solver
maxIter = 100;
visitedStates = [ef];
currentState = ef;
iter = 1;
while not(isequal(currentState, ei)) && iter <= maxIter
    disp("Iteration " + string(iter))
    nextState = [];
    for pred = currentState
        disp(pred)
        [predName, predArgs] = decompose(pred);
        % Infered Actions
        proposedOperators = infereactions(pred);
        for op = proposedOperators
            disp(op)
            [opName, opArgs] = decompose(op);
            opwithparam = contains(op, "p");
            % Used generated opArgs (regardless of parameters)
            [prec, add, del] = action(opName, opArgs);
            
            regoutput = arrayfun(@(p) regression(p, add, del), currentState);
            % if FALSE in regoutput, discard operator,
            % elif parameters, deal with them
            % else check for inconsistencies, give final OK 
            if ismember("FALSE", regoutput)
                disp("FALSE in regout")
                continue
            elseif opwithparam
                disp("DEAL with partial instantiaded")
                % EMPTY-ARM caused by
                %   CL(X) + ON(X,Y) => STACK(X,Y)
                %   CL(X) + ON-T(X) => LEAVE(X)
                switch EMPTYARM
                    
                
            else
                disp("CHECK inconsistencies")
                % HEAVIER, USED-COLS-NUM,LIGHT-BLOCK,
                % INCONSISTENCIES
            end
            % OP is a good candidate
            % NextState = [OP Prec + RegFunOutput]
            
            nextState = sort([prec regoutput(not(regoutput == "TRUE"))]);
           
        end
        
        
    end
    iter = iter + 1;
end



%% Functions
function pred = findEA(state)
    % State is sorted
    actions = [];
    for p = state
        n,a = decompose(p);
        clearArgs = [];
        if n == CLEAR
            clearArgs = [clearArgs a];
        elseif n == ON && ismember(a(1), clearArgs)
            actions = [actions compose(STACK, a)];
        elseif n == ONTABLE && ismember(a, clearArgs)
            actions = [actions compose(LEAVE, a)];
        end            
     
    end
end
% FIND CLEAR(X) + ON(X,Y) -> return X,Y
function regout = regression(pred, add, del)
    if ismember(pred, add)
        regout = "TRUE";
    elseif ismember(pred, del)
        regout = "FALSE";
    else
        regout = pred;
    end
end
function actions = infereactions(pred)
    loadconstants
    [name, args] = decompose(pred);
    switch name
        case ONTABLE
            actions = compose(LEAVE, args);
        case ON
            actions = compose(STACK, args);
        case CLEAR 
            actions = [
                compose(UNSTACKLEFT, ["p", args]) ... 
                compose(UNSTACKRIGHT, ["p", args])
            ];
        case EMPTYARM
            actions = [];
            for p = state
                n,a = decompose(p);
                clearArgs = [];
                if n == CLEAR
                    clearArgs = [clearArgs a];
                elseif n == ON && ismember(a(1), clearArgs)
                    actions = [actions compose(STACK, a)];
                elseif n == ONTABLE && ismember(a, clearArgs)
                    actions = [actions compose(LEAVE, a)];
                end
            end
%             actions = [
%                 compose(STACK, ["p", "p"]) ...
%                 compose(LEAVE, "p")
%             ];
        case HOLDING
            if(args(2) == LEFTARM)
                actions = [
                    compose(PICKUPLEFT, args(1)) ...
                    compose(UNSTACKLEFT, [args(1), "p"])
                ];
            elseif(args(2) == RIGHTARM)
                actions = [
                    compose(PICKUPRIGHT, args(1))
                    compose(UNSTACKRIGHT, [args(1), "p"])
                ];
            end
    end
end

function state = parseState(stateDesc)
    stateDescElems = regexp(stateDesc, '(?<=\)),', 'split');
    state = sort(cellfun(@(p) string(p), stateDescElems));
end

function [predName, predArgs] = decompose(predDesc)
    predElems = regexp(erase(predDesc, ')'), '\(|,', 'split');
    predString = cellfun(@(p) string(p), predElems);
    predName = predString(1);
    predArgs = predString(2:end);
end

function predDesc = compose(predName, predArgs)
    predDesc = predName + "(" + join(predArgs, ',') + ")";
end

function [precond, add, del] = action(actName, actArgs)
    loadconstants
    X = actArgs(1);
    if(size(actArgs, 2) > 1)
        Y = actArgs(2);
    end
    switch actName
        case PICKUPLEFT
            precond = [
                compose(ONTABLE, X) ...
                compose(EMPTYARM, LEFTARM) ...
                compose(CLEAR, X) ...
                compose(LIGHTBLOCK, X)
            ];
            add = [
                compose(HOLDING, [X LEFTARM])% ...
                % compose(USEDCOLSNUM, true) % is a column available?
            ];
            del = [
                compose(ONTABLE, X) ...
                compose(EMPTYARM, LEFTARM)
            ];
        case PICKUPRIGHT
            precond = [
                compose(ONTABLE, X) ...
                compose(EMPTYARM, RIGHTARM) ...
                compose(CLEAR, X)
            ];
            add = [
                compose(HOLDING, [X, RIGHTARM]) %, ...
                % compose(USEDCOLSNUM, true) % is a column available?
            ];
            del = [
                compose(ONTABLE, X) ...
                compose(EMPTYARM, RIGHTARM)
            ];
        case STACK
            precond = [
                compose(HOLDING, [X, "a"]) ...
                compose(CLEAR, Y) ...
                compose(HEAVIER, [Y, X])
            ];
            add = [
                compose(ON, [X, Y]) ...
                compose(EMPTYARM, LEFTARM)
            ];
            del = [
                compose(HOLDING, [X, "a"]) ...
                compose(CLEAR, Y)
            ];
        case UNSTACKLEFT
            precond = [
                compose(ON, [X, Y]) ...
                compose(CLEAR, X) ...
                compose(EMPTYARM, LEFTARM) ...
                compose(LIGHTBLOCK, X)
            ];
            add = [
                compose(HOLDING, [X, LEFTARM]) ...
                compose(CLEAR, Y)
            ];
            del = [
                compose(ON, [X, Y]) ...
                compose(EMPTYARM, LEFTARM)
            ];
        case UNSTACKRIGHT
            precond = [
                compose(ON, [X, Y]) ...
                compose(CLEAR, X) ...
                compose(EMPTYARM, RIGHTARM)
            ];
            add = [
                compose(HOLDING, [X, RIGHTARM]) ...
                compose(CLEAR, Y)
            ];
            del = [
                compose(ON, [X, Y]) ...
                compose(EMPTYARM, RIGHTARM)
            ];
        case LEAVE
            precond = [
                compose(HOLDING, [X, "a"]) ...
                % compose(USEDCOLSNUM, true)
            ];
            add = [
                compose(ONTABLE, X) ...
                compose(EMPTYARM, LEFTARM)
                % compose(USEDCOLSNUM, true) ...
            ];
            del = [
                compose(HOLDING, [X, "a"])
            ];
        otherwise
            error("Unknown action")
    end
end

% Parsing Functions
function blockMap = parseBlocks(blockDesc)
    blocksDefElems = strsplit(blockDesc, ',');
    blockMap = containers.Map( ...
        cellfun(@(e) {e(1)}, blocksDefElems), ...
        cellfun(@(e) count(e(2:end), '*'), blocksDefElems));
end

% Utility Functions
function check = isheavier(blockWeight,blockX,blockY)
    check = (blockWeight(blockX) >= blockWeight(blockY));
end

function check = islightblock(blockWeight,blockX)
    loadconstants
    check = (blockWeight(blockX) == MAXLIGHTWEIGHT);
end
