class SerializeCommunitySolutions
  include Mandate

  initialize_with :solutions

  def call
    # Some upstream callers pass in a manually constructed kaminari array that already
    # includes the exercise and track. For the other callers, we include it here
    solutions_with_includes = solutions.is_a?(ActiveRecord::Relation) ? solutions.includes(:exercise, :track) : solutions

    solutions_with_includes.map do |solution|
      SerializeCommunitySolution.(solution)
    end
  end
end
