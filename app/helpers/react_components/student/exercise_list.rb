module ReactComponents
  module Student
    class ExerciseList < ReactComponent
      initialize_with :track, :params

      def to_s
        super("student-exercise-list", {
          request: request,
          status: params[:status]
        })
      end

      private
      def request
        query = {
          criteria: params[:criteria],
          sideload: ["solutions"]
        }.compact

        {
          endpoint: Exercism::Routes.api_track_exercises_path(track),
          options: {
            initial_data: AssembleExerciseList.(current_user, track, query)
          },
          query: query
        }
      end
    end
  end
end
