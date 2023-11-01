module ReactComponents
  module Contributing
    class SolutionTagger < ReactComponent
      def to_s
        super("contributing-solution-tagger", {
          solution: SerializeSolution.(Solution.last),
          tags: {
            'Boolean': "concept:boolean"
          }
        })
      end
    end
  end
end
