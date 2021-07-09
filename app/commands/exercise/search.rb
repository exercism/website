class Exercise
  class Search
    include Mandate

    def initialize(track, user_track: nil, criteria: nil)
      @track = track
      @user_track = user_track
      @criteria = criteria
    end

    def call
      @exercises = track.exercises
      filter_status!
      filter_criteria!
      sort!
      @exercises
    end

    def filter_status!
      if !user_track || user_track.external?
        @exercises = @exercises.where.not(status: %i[deprecated wip])
      else
        @exercises = @exercises.where.not(status: %i[deprecated wip]).
          or(@exercises.where(id: user_track.solutions.pluck(:exercise_id)))
      end
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

      return if !user_track || user_track.external?

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
    attr_reader :track, :user_track, :criteria
  end
end
