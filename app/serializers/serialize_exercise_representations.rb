class SerializeExerciseRepresentations
  include Mandate

  initialize_with :representations

  def call
    representations.map { |representation| SerializeExerciseRepresentation.(representation) }
  end
end
