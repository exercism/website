module ViewComponents
  module Track
    class ExerciseStatusTag < ViewComponent
      initialize_with :exercise, :user_track

      def to_s
        return tag.div("Work In Progress", class: 'c-exercise-status-tag --wip') if exercise.wip?

        status = user_track.exercise_status(exercise).to_sym
        case status
        when :available
          tag.div("Available", class: 'c-exercise-status-tag --available')
        when :locked
          tag.div("Locked", class: 'c-exercise-status-tag --locked')
        when :started, :iterated
          tag.div("In-progress", class: 'c-exercise-status-tag --in-progress')
        when :completed
          tag.div("Completed", class: 'c-exercise-status-tag --completed')
        when :published
          tag.div("Published", class: 'c-exercise-status-tag --published')
        when :external
          ""
        else
          raise "ExerciseStatusTag: Invalid status: #{status}"
        end
      rescue StandardError => e
        Bugsnag.notify(e)
        ""
      end
    end
  end
end
