class SerializeSolutionsForStudent
  include Mandate

  initialize_with :solutions

  def call
    solutions.map { |s| SerializeSolutionForStudent.(s) }
  end
end
