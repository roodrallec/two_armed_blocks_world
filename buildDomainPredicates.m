function predicates = buildDomainPredicates(blocks, lightWeight)
  % buildDomainPredicates adds predicates needed to implement
  % domain specific restrictions
  predicates = [];

  for b1 = 1:length(blocks)
      l1 = blocks(b1).label;
      w1 = blocks(b1).weight;

      if (w1 == lightWeight)
          predicates = [predicates, Predicate("LIGHT-BLOCK", l1)];
      end

      for b2 = 1:length(blocks)

          if (b1 == b2)
              continue
          end

          l2 = blocks(b2).label;
          w2 = blocks(b2).weight;

          if (w1 >= w2)
              predicates = [predicates, Predicate("HEAVIER", {l1, l2})];
          end

          if (w2 >= w1)
              predicates = [predicates, Predicate("HEAVIER", {l2, l1})];
          end
      end
  end
end
