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
        params.permit(*AssembleExerciseCommunitySolutionsList.keys)
      end
    end
  end
end
