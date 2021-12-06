module ReactComponents
  module Track
    class ExerciseCommunitySolutionsList < ReactComponent
      initialize_with :exercise, :params

      def to_s
        super("track-exercise-community-solutions-list", { request: request })
      end

      private
      def request
        {
          endpoint: Exercism::Routes.api_track_exercise_community_solutions_url(exercise.track, exercise),
          query: search_params,
          options: { initial_data: data }
        }
      end

      def data
        AssembleExerciseCommunitySolutionsList.(exercise, search_params)
      end

      memoize
      def search_params
        permitted = params.permit(*AssembleExerciseCommunitySolutionsList.keys).to_h

        booleans = %w[up_to_date passed_tests not_passed_head_tests]
        permitted.each_with_object({}) do |(k, v), h|
          h[k] = booleans.include?(k) ? ActiveModel::Type::Boolean.new.cast(v) : v
        end
      end
    end
  end
end
