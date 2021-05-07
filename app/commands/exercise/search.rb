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
      filter_criteria!
      sort!
      @exercises
    end

    def filter_criteria!
      return if criteria.blank?

      criteria.strip.split(" ").each do |crit|
        @exercises = @exercises.where(
          "exercises.title LIKE ?",
          "#{crit}%"
        )
      end
    end

    def sort!
      @exercises = @exercises.order(:position)

      return if !user_track || user_track.external?

      mapping = %i[
        iterated started
        available
        completed published
        locked
      ]

      @exercises = @exercises.sort_by do |exercise|
        status = user_track.exercise_status(exercise).to_sym
        modifier = mapping.index(status)

        "#{modifier}0000#{exercise.id}".to_i
      end
    end

    private
    attr_reader :track, :user_track, :criteria
  end
end
