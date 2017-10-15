classdef action
    %ACTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name
        X
        Y
        precond
        add
        del
        
    end
    properties (Constant, Hidden = true)
        pickUpLeft = "PICK-UP-LEFT";  % with arm left, pickup block X
        pickUpRight = "PICK-UP-RIGHT";  % with arm right, pickup block X
        stack = "STACK";  % with arm a, stack block X, on block Y
        unstackLeft = "UNSTACK-LEFT";  % with arm left, un-stack block X, from block Y
        unstackRight = "UNSTACK-RIGHT";  % with arm right, un-stack block X, from block Y
        leave = "LEAVE"  %  with arm a, leave block X on the table
        
        leftArm = predicate.armsIDs(1)
        rightArm = predicate.armsIDs(2)
    end
    
    methods
        function obj = action(name, args)
            %ACTION Construct an instance of this class
            %   Detailed explanation goes here
           % obj.Property1 = inputArg1 + inputArg2;
           obj.name = name;
           obj.X = args(1);
           if(ismember(name, [obj.stack, obj.unstackLeft, ...
                   obj.unstackRight]))
               obj.X = args(1);
           end
           obj.assignconditions()
        end
        
        function obj = assignconditions(obj)
            switch obj.name
                case obj.pickUpLeft
                    obj.precond = {
                        predicate(predicate.onTable, obj.X), ...
                        predicate(predicate.emptyArm, obj.leftArm), ...
                        predicate(predicate.clear, obj.X), ...
                        predicate(predicate.lightBlock, obj.X)
                    };
                    obj.add = {
                        predicate(predicate.holding, obj.X, obj.leftArm), ...
                        predicate(predicate.usedColsNum, true) % TODO: is a column available?
                    };
                    obj.del = {
                        predicate(predicate.onTable, obj.X), ...
                        predicate(predicate.emptyArm, obj.leftArm), ...
                        predicate(predicate.clear, obj.X)
                    };
                case obj.pickUpRight
                    obj.precond = {
                        predicate(predicate.onTable, obj.X), ...
                        predicate(predicate.emptyArm, obj.rightArm), ...
                        predicate(predicate.clear, obj.X), ...
                        predicate(predicate.lightBlock, obj.X)
                    };
                    obj.add = {
                        predicate(predicate.holding, obj.X, obj.rightArm), ...
                        predicate(predicate.usedColsNum, true) % TODO: is a column available?
                    };
                    obj.del = {
                        predicate(predicate.onTable, obj.X), ...
                        predicate(predicate.emptyArm, obj.rightArm), ...
                        predicate(predicate.clear, obj.X)
                    };
                case obj.stack
                    obj.precond = {
                        predicate(predicate.holding, NaN), ...  % the arm is not relevant TODO: check if it works with isequaln
                        predicate(predicate.clear, obj.Y), ...
                        predicate(predicate.heavier(obj.Y, obj.X))  % TODO: list of heavier predicates generated
                    };
                    obj.add = {
                        predicate(predicate.on, obj.X, obj.Y), ...
                        predicate(predicate.emptyArm, NaN), ...  % TODO: instantiate this parameter
                        predicate(predicate.clear, obj.X)
                    };
                    obj.del = {
                        predicate(predicate.holding, NaN), ...  % TODO: instantiate this parameter
                        predicate(predicate.clear, obj.Y)
                    };
                case obj.unstackLeft
                    obj.precond = {
                        predicate(predicate.on, obj.X, obj.Y), ...
                        predicate(predicate.clear, obj.X), ...
                        predicate(predicate.emptyArm, obj.leftArm), ...
                        predicate(predicate.lightBlock, obj.X)
                    };
                    obj.add = {
                        predicate(predicate.holding, obj.X, obj.leftArm), ...
                        predicate(predicate.clear, obj.Y)
                    };
                    obj.del = {
                        predicate(predicate.on, obj.X, obj.Y), ...
                        predicate(predicate.emptyArm, obj.leftArm), ...
                        predicate(predicate.clear, obj.X)
                    };
                case obj.unstackRight
                    obj.precond = {
                        predicate(predicate.on, obj.X, obj.Y), ...
                        predicate(predicate.clear, obj.X), ...
                        predicate(predicate.emptyArm, obj.rightArm)
                    };
                    obj.add = {
                        predicate(predicate.holding, obj.X, obj.rightArm), ...
                        predicate(predicate.clear, obj.Y)
                    };
                    obj.del = {
                        predicate(predicate.on, obj.X, obj.Y), ...
                        predicate(predicate.emptyArm, obj.rightArm), ...
                        predicate(predicate.clear, obj.X)
                    };
                case obj.leave
                    obj.precond = {
                        predicate(predicate.holding, NaN), ...
                        predicate(predicate.usedColsNum, true)  % TODO: is a Column available?
                    };
                    obj.add = {
                        predicate(predicate.onTable, obj.X), ...
                        predicate(predicate.emptyArm, NaN), ...  % TODO: instantiate this parameter
                        predicate(predicate.usedColsNum, true), ...
                        predicate(predicate.clear, obj.X)
                    };
                    obj.del = {
                        predicate(predicate.holding, NaN)  % TODO: instantiate this parameter
                    };
                otherwise
                    error("Unknown action")
            end
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

