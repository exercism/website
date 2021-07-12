module ReactComponents
  module Student
    class ExerciseList < ReactComponent
      initialize_with :track, :params

      def to_s
        super("student-exercise-list", { request: request })
      end

      private
      def request
        {
          endpoint: Exercism::Routes.api_track_exercises_path(track),
          options: {
            initial_data: AssembleExerciseList.(
              current_user,
              track,
              params.merge(sideload: ["solutions"])
            )
          },
          query: { sideload: ["solutions"] }
        }
      end
    end
  end
end
