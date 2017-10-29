classdef BlockOperator < Operator

    properties
        name
        arm
        block1
        block2
        cols
    end

    methods
        function obj = BlockOperator(name, arm, block1, block2, cols)
            obj = obj@Operator(BlockOperator.buildLabel(name, arm, block1, block2, cols));
            obj.name = name;
            obj.arm = arm;
            obj.block1 = block1;
            obj.block2 = block2;
            obj.cols = cols;
        end
    end

    methods(Static)
        function label = buildLabel(name, arm, block1, block2, cols)
            label = "name=" + char(name) + ";"...
                  + "arm=" + char(arm) + ";"...
                  + "block1=" + char(block1) + ";"...
                  + "block2=" + char(block2) + ";"...
                  + "cols=" + char(cols) + ";";
        end
    end
end
