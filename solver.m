classdef solver
    %SOLVER Implementation of a Non-linear pleanner with regression
    %   Detailed explanation goes here
    
    properties
        initialState
        finalState
    end
    
    methods
        function obj = solver(initialState,finalState)
            %SOLVER Construct an instance of this class
            %   Detailed explanation goes here
            obj.initialState = initialState;
            obj.finalState = finalState;
            
            infereactions(obj.initialState.predicates{1})
            
            
        end
        
        function actions = infereactions(obj, pred)
            switch pred.name
                case predicate.onTable
                    actions = {
                        action(action.leaveLeft, pred.X), ...
                        action(action.leaveRight, pred.X)
                    };
                case predicate.on
                    actions = {
                        action(action.stackLeft, pred.X, pred.Y), ...
                        action(action.stackRight, pred.X, pred.Y), ...
                    };
                case predicate.clear
                    actions = {
                        action(action.stackLeft, pred.X, NaN), ... % partially instantiated
                        action(action.stackRight, pred.X, NaN), ...
                        action(action.unstackLeft, NaN, pred.X), ...
                        action(action.unstackRight, NaN, pred.X), ...
                        action(action.leaveLeft, pred.X), ...
                        action(action.leaveRight, pred.X)
                    };
                case predicate.pre
                    
            
        end
    end
end
 
