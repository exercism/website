module ReactComponents
  module Student
    class SolutionSummary < ReactComponent
      initialize_with :iteration

      def to_s
        super("student-solution-summary", {
          solution_id: iteration.solution.uuid,
          iteration: SerializeIteration.(iteration),
          is_practice_exercise: iteration.exercise.practice_exercise?,
          links: links
        })
      end

      private
      def links
        {
          tests_passed_locally_article: "#",
          all_iterations: Exercism::Routes.track_concepts_path(iteration.track),
          community_solutions: "#",
          learn_more_about_mentoring_article: "#"
        }
      end
    end
  end
end
