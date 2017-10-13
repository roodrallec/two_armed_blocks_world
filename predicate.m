classdef predicate
    %PREDICATE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name
        X
        Y
        a
        n
        isHeavier
        isLightBlock
        
    end
    properties (Constant, Hidden = true)
        onTable = "ON-TABLE";
        on = "ON";
        clear = "CLEAR";
        emptyArm = "EMPTY-ARM";
        holding = "HOLDING";
        usedColsNum = "USED-COLS-NUM";
        heavier = "HEAVIER";
        lightBlock = "LIGHT-BLOCK";
        
        armsIDs = ["L", "R"];
        maxLightWeight = 1;
    end
    
    methods
        function obj = predicate(name, args)
            %PREDICATE Construct an instance of this class
            %   Detailed explanation goes here
            
            % disp(name)
            switch name
                case obj.onTable 
                    obj.X = args(1);
                case obj.on
                    obj.X = args(1);
                    obj.Y = args(2);
                case obj.clear
                    obj.X = args(1);
                case obj.emptyArm
                    if not(ismember(args(1), obj.armsIDs))
                        error("The robotic arm id is not valid");
                    end
                    obj.a = args(1);
                case obj.holding
                    obj.X = args(1);
                    obj.a = string(args(2));
                case obj.usedColsNum
                    obj.n = args(1);
                case obj.heavier
                    obj.X = args(1);
                    obj.Y = args(2);
                    obj.isHeavier = obj.X.weight >= obj.Y.weight;
                case obj.lightBlock
                    obj.X = args(1);
                    obj.isLightBlock = obj.X.weight <= obj.maxLightWeight;
                otherwise
                    error("Unknown predicate")
            end
            obj.name = name;
        end
    
        function desc = print(obj)
            %PREDICATE Construct an instance of this class
            %   Detailed explanation goes here
            switch obj.name
                case obj.onTable 
                    printArgs = obj.X.label;
                case obj.on
                    printArgs = [obj.X.label, obj.Y.label];
                case obj.clear
                    printArgs = obj.X.label;
                case obj.emptyArm
                    printArgs = obj.a;
                case obj.holding
                    printArgs = [obj.X.label, obj.a];
                case obj.usedColsNum
                    printArgs = obj.n;
                case obj.heavier
                    printArgs = [obj.X.label, obj.Y.label, obj.isHeavier];
                case obj.lightBlock
                    printArgs = [obj.X.label, obj.isLightBlock];
                otherwise
                    error("Unknown predicate")
            end
            desc = obj.name + "(" + join(printArgs, ",") + ")";
        end
    end
end
