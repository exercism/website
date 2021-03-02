module ReactComponents
  module Student
    class SolutionSummary < ReactComponent
      initialize_with :iteration

      def to_s
        super("student-solution-summary", {
          iteration: SerializeIteration.(iteration),
          is_practice_exercise: iteration.exercise.practice_exercise?,
          links: links
        })
      end

      private
      def links
        {
          tests_passed_locally_article: "TODO"
        }
      end
    end
  end
end
