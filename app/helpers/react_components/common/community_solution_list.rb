module ReactComponents
  module Common
    class CommunitySolutionList < ReactComponent
      initialize_with :exercise, :context

      def to_s
        super("common-community-solution-list", {
          request: request,
          context: context
        })
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
