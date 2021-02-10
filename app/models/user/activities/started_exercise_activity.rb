module User::Activities
  class StartedExerciseActivity < User::Activity
    before_create do
      self.occurred_at = solution.created_at
    end

    def url
      Exercism::Routes.track_exercise_path(track, solution.exercise)
    end

    def icon_name
      "editor"
    end

    def guard_params
      "Solution##{solution.id}"
    end

    def i18n_params
      {
        exercise_title: solution.exercise.title
      }
    end
  end
end
