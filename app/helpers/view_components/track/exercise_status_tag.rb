module ViewComponents
  module Track
    class ExerciseStatusTag < ViewComponent
      initialize_with :exercise, :user_track

      def to_s
        case user_track.exercise_status(exercise).to_sym
        when :available
          tag.div("Available", class: 'c-exercise-status-tag --available')
        when :locked
          tag.div("Locked", class: 'c-exercise-status-tag --locked')
        when :started
          tag.div("Started", class: 'c-exercise-status-tag --started')
        when :in_progress
          tag.div("In progress", class: 'c-exercise-status-tag --in-progress')
        when :completed
          tag.div("Completed", class: 'c-exercise-status-tag --completed')
        when :published
          tag.div("Published", class: 'c-exercise-status-tag --published')
        end
      end
    end
  end
end
