class Exercise
  class Search
    include Mandate

    def initialize(track, criteria: nil)
      @track = track
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
      # TOOD: Formalise this from the config.json
      @exercises = @exercises.order('id')
    end

    private
    attr_reader :track, :criteria
  end
end
