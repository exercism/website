module ViewComponents
  module Track
    class ExerciseStatusTag < ViewComponent
      initialize_with :exercise, :user_track

      def to_s
        if exercise.wip?
          return tag.div(I18n.t("components.track.exercise_status_tag.work_in_progress"),
            class: 'c-exercise-status-tag --wip')
        end

        status = user_track.exercise_status(exercise).to_sym
        case status
        when :available
          tag.div(I18n.t("components.track.exercise_status_tag.available"), class: 'c-exercise-status-tag --available')
        when :locked
          tag.div(I18n.t("components.track.exercise_status_tag.locked"), class: 'c-exercise-status-tag --locked')
        when :started, :iterated
          tag.div(I18n.t("components.track.exercise_status_tag.in_progress"), class: 'c-exercise-status-tag --in-progress')
        when :completed
          tag.div(I18n.t("components.track.exercise_status_tag.completed"), class: 'c-exercise-status-tag --completed')
        when :published
          tag.div(I18n.t("components.track.exercise_status_tag.published"), class: 'c-exercise-status-tag --published')
        when :external
          ""
        else
          raise "ExerciseStatusTag: Invalid status: #{status}"
        end
      rescue StandardError => e
        Sentry.capture_exception(e)
        ""
      end
    end
  end
end
