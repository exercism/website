class Exercise
  class Search
    include Mandate

    def initialize(user_track, criteria: nil)
      @user_track = user_track
      @criteria = criteria
    end

    def call
      @exercises = user_track.exercises
      filter_criteria!
      sort!
      @exercises
    end

    def filter_criteria!
      return if criteria.blank?

      criteria.strip.split(" ").each do |crit|
        @exercises = @exercises.where(
          "exercises.title LIKE ?",
          "%#{crit}%"
        )
      end
    end

    def sort!
      @exercises = @exercises.order(:position).to_a

      return if user_track.external?

      mapping = %i[
        iterated started
        available
        completed published
        locked
      ]

      @exercises.sort_by! do |exercise|
        status = user_track.exercise_status(exercise).to_sym
        status_modifier = mapping.index(status)
        type_modifier = exercise.concept_exercise? ? 0 : 1

        "#{status_modifier}#{type_modifier}#{exercise.position.to_s.rjust(5, '0')}".to_i
      end
    end

    private
    attr_reader :user_track, :criteria
  end
end
