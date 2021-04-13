module ReactComponents
  module Track
    class ExerciseCommunitySolutionsList < ReactComponent
      initialize_with :exercise

      def to_s
        super("track-exercise-community-solutions-list", { request: request })
      end

      private
      def request
        {
          endpoint: Exercism::Routes.api_track_exercise_community_solutions_url(exercise.track, exercise),
          options: { initial_data: data }
        }
      end

      def data
        SerializePaginatedCollection.(
          Solution::SearchCommunitySolutions.(exercise),
          serializer: SerializeCommunitySolutions,
          meta: {
            unscoped_total: exercise.solutions.published.count
          }
        )
      end
    end
  end
end
