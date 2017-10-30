function operators = buildOperators(arms, blocks, maxCols, weakArm, lightWeight)
    %% BUILD DOMAIN OPERATORS:
    % Operators:
    % "PICK-UP", A, X
    % "LEAVE", A, X, C
    % "STACK", A, X, Y
    % "UNSTACK", A, X, Y, C
    %% POSSIBLE PREDICATES
    % ON-TABLE(domain.blocksMap.label)
    % ON(domain.blocksMap.label, domain.blocksMap.label)
    % CLEAR(domain.blocksMap.label)
    % EMPTY-ARM(arms)
    % HOLDING(domain.blocksMap.label, arms)
    % USED-COLS-NUM(range(1..maxCols))
    % HEAVIER(domain.blocksMap.label, domain.blocksMap.label)
    % LIGHT-BLOCK(domain.blocksMap.label)
    operators = [];
    for a = 1:length(arms)
        % Every operator must use an arm and therefore every arm iteration
        % generates an operator variation
        arm = arms{a};
        for b1 = 1:length(blocks)
            block1 = blocks(b1);
            % DOMAIN KNOWLEDGE
            if (arm == weakArm) && (block1.weight ~= lightWeight)
              continue
            end
            % Every operator must operate on a first block
            % so an opeartor is build for each arm block combination
            for c = 1:maxCols
                % Some operators depend on the columns too, we apply
                % those conditions here
                %% "PICK-UP" operators are built
                % The relevant preconditions added
                % Weak arm rule check
                % The relevent add conditions added
                % The relevant del conditions added
                % The operator is built and is added to the Operators array
                pickupOperator = BlockOperator("PICK-UP", arm, block1.label, "", c);
                pickupOperator.preConditions = [Predicate("ON-TABLE", block1.label), Predicate("CLEAR", block1.label), Predicate("EMPTY-ARM", arm), Predicate("USED-COLS-NUM", c)];
                pickupOperator.add = [Predicate("HOLDING", [block1.label, arm]), Predicate("USED-COLS-NUM", c-1)];
                pickupOperator.del = [Predicate("ON-TABLE", block1.label), Predicate("CLEAR", block1.label), Predicate("EMPTY-ARM", arm)];
                operators = [operators, pickupOperator];
                %% "LEAVE" operators are built
                % Here rule 2 is applied to ensure the max col limit
                % The relevant preconditions added
                % The relevent add conditions added
                % The relevant del conditions added
                % Once the operator is built it's added to the Operators array
                % DOMAIN KNOWLEDGE

                %if (c == maxCols)
                %    continue
                %end
                leaveOperator = BlockOperator("LEAVE", arm, block1.label, "", c+1);
                leaveOperator.preConditions = [Predicate("HOLDING", [block1.label, arm]), Predicate("USED-COLS-NUM", c)];
                leaveOperator.add = [Predicate("ON-TABLE", block1.label), Predicate("EMPTY-ARM", arm), Predicate("USED-COLS-NUM", c+1), Predicate("CLEAR", block1.label)];
                leaveOperator.del = [Predicate("HOLDING", [block1.label, arm])];
                operators = [operators, leaveOperator];
            end

            for b2 = 1:length(blocks)
                % Some operators operate on a second block, build those here
                block2 = blocks(b2);
                % Ignore operations of the same block
                % DOMAIN KNOWLEDGE
                if block1.label == block2.label
                    continue
                end
                % Prevent heavy blocks from being added
                % DOMAIN KNOWLEDGE
                if block1.weight > block2.weight
                    continue
                end
                %% Here the "STACK" operators are built
                % The relevant preconditions added
                % The relevent add conditions added
                % The relevant del conditions added
                % Once the operator is build its added to the Operators array
                stackOperator = BlockOperator("STACK", arm, block1.label, block2.label, "");
                stackOperator.preConditions = [Predicate("HOLDING", [block1.label, arm]), Predicate("CLEAR", block2.label)];
                stackOperator.add = [Predicate("ON", {block1.label, block2.label}), Predicate("EMPTY-ARM", arm), Predicate("CLEAR", block1.label)];
                stackOperator.del = [Predicate("HOLDING", [block1.label, arm]), Predicate("CLEAR", block2.label)];
                operators = [operators, stackOperator];
                %% Here the "UN-STACK" operators are built
                % The relevant preconditions added
                % Weak arm rule check
                % The relevent add conditions added
                % The relevant del conditions added
                % Once the operator is build its added to the Operators array
                unStackOperator = BlockOperator("UN-STACK", arm, block1.label, block2.label, "");
                unStackOperator.preConditions = [Predicate("ON", {block1.label, block2.label}), Predicate("CLEAR", block1.label), Predicate("EMPTY-ARM", arm)];
                unStackOperator.add = [Predicate("HOLDING", [block1.label, arm]), Predicate("CLEAR", block2.label)];
                unStackOperator.del = [Predicate("ON", {block1.label, block2.label}), Predicate("EMPTY-ARM", arm), Predicate("CLEAR", block1.label)];
                operators = [operators, unStackOperator];
            end
        end
    end
end
