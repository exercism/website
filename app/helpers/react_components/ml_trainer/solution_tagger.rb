module ReactComponents
  module MLTrainer
    class SolutionTagger < ReactComponent
      def to_s
        super("ml-trainer-solution-tagger", {
          solution: SerializeSolution.(Solution.last),
          tags: {
            'Boolean': "concept:boolean"
          }
        })
      end
    end
  end
end
