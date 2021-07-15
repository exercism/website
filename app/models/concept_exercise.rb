class ConceptExercise < Exercise
  has_many :exercise_taught_concepts,
    class_name: "Exercise::TaughtConcept",
    foreign_key: :exercise_id,
    inverse_of: :exercise,
    dependent: :destroy

  has_many :taught_concepts,
    through: :exercise_taught_concepts,
    source: :concept

  def self.that_teach(concepts)
    joins(:taught_concepts).
      where('exercise_taught_concepts.track_concept_id': concepts)
  end

  def unlocked_exercises
    Exercise.where(
      id: taught_concepts.
          joins(:exercise_prerequisites).
          select('exercise_prerequisites.exercise_id')
    )
  end

  def unlocked_concepts
    Concept.joins(:exercise_taught_concepts).where(
      'exercise_taught_concepts.exercise_id': taught_concepts.
        joins(:exercise_prerequisites).
        select('exercise_prerequisites.exercise_id')
    )
  end
end
