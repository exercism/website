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
          query: params.slice(*AssembleExerciseCommunitySolutionsList.keys),
          options: { initial_data: data }
        }
      end

      def data
        AssembleExerciseCommunitySolutionsList.(exercise, params)
      end
    end
  end
end
