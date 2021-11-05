class SerializeCommunitySolutions
  include Mandate

  initialize_with :solutions

  def call
    solutions.map do |solution|
      SerializeCommunitySolution.(solution)
    end
  end
end
