class SerializeCommunitySolutions
  include Mandate

  initialize_with :solutions

  def call
    solutions.includes(:exercise, :track).map do |solution|
      SerializeCommunitySolution.(solution)
    end
  end
end
