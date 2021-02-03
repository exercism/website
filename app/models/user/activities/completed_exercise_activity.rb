module User::Activities
  class CompletedExerciseActivity < User::Activity
    before_create do
      self.occurred_at = solution.completed_at
    end

    def url
      Exercism::Routes.track_exercise_path(track, solution.exercise)
    end

    def cachable_rendering_data
      super.merge(
        occurred_at: solution.completed_at
      )
    end

    def guard_params
      "Solution##{solution.id}"
    end
  end
end
