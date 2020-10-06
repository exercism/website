class ConceptExercise < Exercise
  has_many :exercise_taught_concepts,
    class_name: "Exercise::TaughtConcept",
    foreign_key: :exercise_id,
    inverse_of: :exercise,
    dependent: :destroy

  has_many :taught_concepts,
    through: :exercise_taught_concepts,
    source: :concept
end
