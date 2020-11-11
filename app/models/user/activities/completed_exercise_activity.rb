module User::Activities
  class CompletedExerciseActivity < User::Activity
    params :exercise

    def url
      Exercism::Routes.track_exercise_path(track, exercise)
    end

    def cachable_rendering_data
      super.merge(
        exercise_title: exercise.title,
        exercise_icon_name: exercise.icon_name
      )
    end

    def guard_params
      "Exercise##{exercise.id}"
    end

    def grouping_params
      "Exercise##{exercise.id}"
    end
  end
end
