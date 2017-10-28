function operators = buildOperators(arms, blocks, maxCols)
    %% BUILD OPERATORS:
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

    operators = {};    
    idx = 1;
    % Every operator must use an arm and therefore every arm iteration 
    % generates an operator variation
    for a = 1:length(arms)        
        arm = arms{a};
        % Every operator must operate on a first block
        % so an opeartor is build for each arm block combination
        for b1 = 1:length(blocks)
            block1 = blocks(b1).label;          
            % Some operators depend on the columns too, we apply 
            % those conditions here
            for c = 1:maxCols
                % Here the "PICK-UP" operators are built
                operators{idx} = Operator(...
                    "PICK-UP(" + arm + "," + block1 + "," + num2str(c) + ")",...
                    {... 
                        Predicate("ON-TABLE", block1),...
                        Predicate("CLEAR", block1),...
                        Predicate("LIGHT-BLOCK", block1),...
                        Predicate("EMPTY-ARM", arm),...
                        Predicate("USED-COLS-NUM", num2str(c))...
                    }, {...
                        Predicate("HOLDING", [block1, arm]),...
                        Predicate("USED-COLS-NUM", num2str(c-1))...
                    }, {...
                        Predicate("ON-TABLE", block1),...
                        Predicate("CLEAR", block1),...
                        Predicate("EMPTY-ARM", arm)...
                    }...
                );
                idx = idx + 1;
                % Here the "LEAVE" operators are built
                operators{idx} = Operator(...
                    "LEAVE(" + arm + "," + block1 + "," + num2str(c) + ")",...
                    {... 
                        Predicate("HOLDING", [block1, arm]),...
                        Predicate("USED-COLS-NUM", c)...
                    }, {...
                        Predicate("ON-TABLE", block1),...                        
                        Predicate("EMPTY-ARM", arm),...
                        Predicate("USED-COLS-NUM", num2str(c+1)),...
                        Predicate("CLEAR", block1)...
                    }, {...
                        Predicate("HOLDING", [block1, arm])...
                    }...
                );
                idx = idx + 1;            
            end            

            % Some operators operate on a second block, build those here
            for b2 = 1:length(blocks)
                block2 = blocks(b2).label;
                
                % Here the "STACK" operators are built
                operators{idx} = Operator(...
                    "STACK(" + arm + "," + block1 + "," + block2 + ")",...
                    {... 
                        Predicate("HOLDING", [block1, arm]),...
                        Predicate("CLEAR", block2),...
                        Predicate("HEAVIER", [block2, block1]),...
                    }, {...
                        Predicate("ON", [block1, block2]),...
                        Predicate("EMPTY-ARM", arm),...
                        Predicate("CLEAR", block1)...
                        
                    }, {...
                        Predicate("HOLDING", [block1, arm]),...
                        Predicate("CLEAR", block2)
                    }...
                );
                idx = idx + 1;
                % Here the "UN-STACK" operators are built
                operators{idx} = Operator(...
                    "UN-STACK(" + arm + "," + block1 + "," + block2 + ")",...
                    {...
                        Predicate("ON", [block1, block2]),...                        
                        Predicate("CLEAR", block1),...
                        Predicate("EMPTY-ARM", arm)...                        
                    }, {...
                        Predicate("HOLDING", [block1, arm]),...                        
                        Predicate("CLEAR", block2)...
                    }, {...
                        Predicate("ON", [block1, block2]),...                        
                        Predicate("EMPTY-ARM", arm),...
                        Predicate("CLEAR", block1)...
                    }...
                );
                idx = idx + 1;                
            end
        end
    end
end
