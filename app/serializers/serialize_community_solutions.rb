class SerializeCommunitySolutions
  include Mandate

  initialize_with :solutions

  def call
    solutions_with_includes.map do |solution|
      SerializeCommunitySolution.(solution)
    end
  end

  def solutions_with_includes
    solutions.to_active_relation.
      includes(:exercise, :track, :user, :published_exercise_representation)
  end
end
