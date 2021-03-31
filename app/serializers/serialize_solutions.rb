class SerializeSolutions
  include Mandate

  initialize_with :solutions

  def call
    solutions.includes(:exercise, :track).
      map { |s| SerializeSolution.(s) }
  end
end
