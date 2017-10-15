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
        pickUpLeft = "PICK-UP-LEFT";    % with arm left, pickup block X
        pickUpRight = "PICK-UP-RIGHT";  % with arm right, pickup block X
        stackLeft = "STACK-LEFT";       % with arm left, stack block X, on block Y
        stackRight = "STACK-RIGHT";     % with arm right, stack block X, on block Y
        unstackLeft = "UNSTACK-LEFT";   % with arm left, un-stack block X, from block Y
        unstackRight = "UNSTACK-RIGHT"; % with arm right, un-stack block X, from block Y
        leaveLeft = "LEAVE-LEFT";       %  with arm left, leave block X on the table
        leaveRight = "LEAVE-RIGHT";     %  with arm right, leave block X on the table
        
        leftArm = predicate.armsIDs(1);
        rightArm = predicate.armsIDs(2);
    end
    
    methods
        function obj = action(name, args)
            %ACTION Construct an instance of this class
            %   Detailed explanation goes here
           % obj.Property1 = inputArg1 + inputArg2;
           obj.name = name;
           obj.X = args(1);
           if(ismember(name, [obj.stackLeft, obj.stackRight, ...
                   obj.unstackLeft, obj.unstackRight]))
               obj.Y = args(2);
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
                        predicate(predicate.holding, obj.X, obj.leftArm)%, ...
                        % predicate(predicate.usedColsNum, true) % is a column available?
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
                        predicate(predicate.holding, obj.X, obj.rightArm) %, ...
                        % predicate(predicate.usedColsNum, true) % is a column available?
                    };
                    obj.del = {
                        predicate(predicate.onTable, obj.X), ...
                        predicate(predicate.emptyArm, obj.rightArm), ...
                        predicate(predicate.clear, obj.X)
                    };
                case obj.stackLeft
                    obj.precond = {
                        predicate(predicate.holding, obj.leftArm), ...
                        predicate(predicate.clear, obj.Y), ...
                        predicate(predicate.heavier(obj.Y, obj.X))
                    };
                    obj.add = {
                        predicate(predicate.on, obj.X, obj.Y), ...
                        predicate(predicate.emptyArm, obj.leftArm), ...
                        predicate(predicate.clear, obj.X)
                    };
                    obj.del = {
                        predicate(predicate.holding, obj.leftArm), ...
                        predicate(predicate.clear, obj.Y)
                    };
                case obj.stackRight
                    obj.precond = {
                        predicate(predicate.holding, obj.rightArm), ...
                        predicate(predicate.clear, obj.Y), ...
                        predicate(predicate.heavier(obj.Y, obj.X))
                    };
                    obj.add = {
                        predicate(predicate.on, obj.X, obj.Y), ...
                        predicate(predicate.emptyArm, obj.rightArm), ...
                        predicate(predicate.clear, obj.X)
                    };
                    obj.del = {
                        predicate(predicate.holding, obj.rightArm), ...
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
                case obj.leaveLeft
                    obj.precond = {
                        predicate(predicate.holding, obj.leftArm), ...
                        predicate(predicate.usedColsNum, true)
                    };
                    obj.add = {
                        predicate(predicate.onTable, obj.X), ...
                        predicate(predicate.emptyArm, obj.leftArm), ...
                        predicate(predicate.clear, obj.X)
                        % predicate(predicate.usedColsNum, true), ...
                    };
                    obj.del = {
                        predicate(predicate.holding, obj.leftArm)
                    };
                case obj.leaveRight
                    obj.precond = {
                        predicate(predicate.holding, obj.rightArm), ...
                        predicate(predicate.usedColsNum, true)
                    };
                    obj.add = {
                        predicate(predicate.onTable, obj.X), ...
                        predicate(predicate.emptyArm, obj.rightArm), ...
                        predicate(predicate.clear, obj.X)
                        % predicate(predicate.usedColsNum, true), ...
                    };
                    obj.del = {
                        predicate(predicate.holding, obj.rightArm)
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

