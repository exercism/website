class ConceptExercise < Exercise
  has_many :exercise_taught_concepts,
    class_name: "Exercise::TaughtConcept",
    foreign_key: :exercise_id,
    inverse_of: :exercise,
    dependent: :destroy

  has_many :taught_concepts,
    through: :exercise_taught_concepts,
    source: :concept

  def self.that_teach(concept)
    joins(:taught_concepts).
      where('exercise_taught_concepts.track_concept_id': concept)
  end
end
