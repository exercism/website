module User::Activities
  class StartedExerciseActivity < User::Activity
    def url
      Exercism::Routes.track_exercise_path(track, exercise)
    end

    def i18n_params
      {}
    end

    def guard_params
      "Exercise##{exercise.id}"
    end

    def grouping_params
      "Exercise##{exercise.id}"
    end

    def exercise
      params[:exercise]
    end
  end
end
