classdef planner
    %PLANNER Implementation of a Non-linear planner with regression
    %   Given an inital state and final state the planner builds a graph of
    %   goal nodes linked with actions, which can then be traversed with a
    %   search algorithm.
    
    properties
        initialState
        finalState
        searchType = 'breadth';
    end
    
    methods
        function obj = planner(initialState, finalState)
            %SOLVER Construct an instance of this class
            %   Detailed explanation goes here
            obj.initialState = initialState;
            obj.finalState = finalState;            
        end
        
        function plan = run()
            obj.finished = false;
            rootNode = node(obj.finalState.predicates);            
            tree = [rootNode];
            
            while obj.nodesLeft(tree) == true
                node = nextNode(tree, obj.searchType);
                obj.expandNode(tree, node);
                children = obj.getChildren(node);
                
                if containsState(obj.initialState, children)
                    obj.finished = true;
                    plan = buildPath(obj.initialState, obj.finalState, tree);
                end    
                    
            end
            
            if obj.finished == false
                error('No way could be found to reach Ei from Ef');
            end          
        end
        
        function bool = nodesLeft(tree)
            % return true if unexpanded nodes
            expanded = cellfun(@(c) c.expanded, predicates, 'UniformOutput', false);
            a = arrayfun(@(n) s.f2 < 30, length(s.f2));
            s = s(a);
            bool = tree;
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
                end
        end
        % Function
    end
end
 
