module User::Activities
  class SubmittedIterationActivity < User::Activity
    def url
      Exercism::Routes.track_exercise_iterations_path(track, exercise, idx: iteration.idx)
    end

    def i18n_params
      {}
    end

    def guard_params
      "Iteration##{iteration.id}"
    end

    def grouping_params
      "Exercise##{exercise.id}"
    end

    def exercise
      params[:exercise]
    end

    def iteration
      params[:iteration]
    end
  end
end
