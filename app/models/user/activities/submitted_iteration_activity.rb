module User::Activities
  class SubmittedIterationActivity < User::Activity
    params :iteration

    before_create do
      self.occurred_at = iteration.created_at
    end

    def url = Exercism::Routes.track_exercise_iteration_path(track, solution.exercise, iteration)
    def icon_name = "iteration"

    def i18n_params
      {
        iteration_idx: iteration.idx
      }
    end

    def guard_params = "Iteration##{iteration.id}"
  end
end
