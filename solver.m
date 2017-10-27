classdef solver
    %SOLVER Implementation of a Non-linear pleanner with regression
    %   Detailed explanation goes here
    
    properties
        initialState
        finalState
        
        maxIter = 100;
        verbose = true;
    end
    
    methods
        function obj = solver(initialState, finalState)
            %SOLVER Construct an instance of this class
            %   Detailed explanation goes here
            obj.initialState = initialState;
            obj.finalState = finalState;
            
            obj.engine();
             
        end
        function engine(obj)
            visitedStates = [];
            currentState = obj.finalState;
            iter = 1;
            while not(currentState.isequal(obj.initialState.predicates)) ...
                    && iter < obj.maxIter
                disp("Iteration " + string(iter));
                
                ia = obj.infereactions(obj.finalState.predicates{2});
                obj.regression(obj.finalState.predicates{2}, ia{2})
                
                iter = iter + 1;
            end
        end
        
        % Heuristics to minimze the action to iterate over
        function actions = infereactions(obj, pred)
            switch pred.name
                case predicate.onTable
                    actions = {
                        action(action.leaveLeft, pred.X), ...
                        action(action.leaveRight, pred.X)
                    };
                case predicate.on
                    actions = {
                        action(action.stackLeft, [pred.X, pred.Y]), ...
                        action(action.stackRight, [pred.X, pred.Y]), ...
                    };
                case predicate.clear
                    actions = {
                        action(action.stackLeft, [pred.X, NaN]), ... % partially instantiated
                        action(action.stackRight, [pred.X, NaN]), ...
                        action(action.unstackLeft, [NaN, pred.X]), ...
                        action(action.unstackRight, [NaN, pred.X]), ...
                        action(action.leaveLeft, pred.X), ...
                        action(action.leaveRight, pred.X)
                    };
                case predicate.emptyArm
                    if(pred.a == action.leftArm)
                        actions = {
                            action(action.stackLeft, [pred.X, NaN]), ...
                            action(action.leaveLeft, pred.X)
                        };
                    elseif(pred.a == action.rightArm)
                        actions = {
                            action(action.stackRight, [pred.X, NaN]), ...
                            action(action.leaveRight, pred.X)
                        };
                    end
                case predicate.holding
                    if(pred.a == action.leftArm)
                        actions = {
                            action(action.pickUpLeft, pred.X), ...
                            action(action.unstackLeft, [pred.X, NaN])
                        };
                    elseif(pred.a == action.rightArm)
                        actions = {
                            action(action.pickUpRight, [pred.X, NaN]), ...
                            action(action.unstackRight, [pred.X, NaN])
                        };
                    end
                otherwise
                    actions = {};
            end
        end
        % Function
    end
    methods(Static)
        function regoutput = regression(pred, action)
            x = 3;
            isequal(pred,action.add(1))
            x = action.add(1);
            
            
        
        end
        function check = contains(obj, pred, preds)
            % Using nested cellfuns instead of double for loops.
            % For each p in the given predicates, check if p is equal to 
            % any object's predicates. 
            check = cellfun(@(p) ...
                cellfun(@(op) isequal(op,p), preds), ...
                preds, 'UniformOutput', false);
            check = logical(sum(cell2mat(check'),1));
        end
        function check = ismember(obj, pred)
            check = any(obj.contains(pred));
        end
    end
end
 
