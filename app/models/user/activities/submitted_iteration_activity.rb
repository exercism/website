module User::Activities
  class SubmittedIterationActivity < User::Activity
    params :exercise, :iteration

    def url
      Exercism::Routes.track_exercise_iteration_path(track, exercise, iteration)
    end

    def rendering_data
      super.tap do |data|
        data.iteration = iteration
      end
    end

    def cachable_rendering_data
      super.merge(
        exercise_title: exercise.title,
        exercise_icon_name: exercise.icon_name
      )
    end

    def guard_params
      "Iteration##{iteration.id}"
    end

    def grouping_params
      "Exercise##{exercise.id}"
    end
  end
end
