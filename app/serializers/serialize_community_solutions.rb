class SerializeCommunitySolutions
  include Mandate

  def initialize(solutions)
    @solutions = solutions
  end

  def call
    solutions.includes(:exercise, :track).map do |solution|
      SerializeCommunitySolution.(solution)
    end
  end

  private
  attr_reader :solutions
end
