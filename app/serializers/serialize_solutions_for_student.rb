class SerializeSolutionsForStudent
  include Mandate

  initialize_with :solutions

  def call
    solutions.includes(:exercise, :track).
      map { |s| SerializeSolutionForStudent.(s) }
  end
end
