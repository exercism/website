module User::Activities
  class StartedExerciseActivity < User::Activity
    before_create do
      self.occurred_at = solution.created_at
    end

    def url = Exercism::Routes.track_exercise_path(track, solution.exercise)
    def icon_name = "editor"
    def guard_params = "Solution##{solution.id}"

    def i18n_params
      {
        exercise_title: solution.exercise.title
      }
    end
  end
end
