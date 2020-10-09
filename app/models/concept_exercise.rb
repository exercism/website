class ConceptExercise < Exercise
  has_many :exercise_taught_concepts,
    class_name: "Exercise::TaughtConcept",
    foreign_key: :exercise_id,
    inverse_of: :exercise,
    dependent: :destroy

  has_many :taught_concepts,
    through: :exercise_taught_concepts,
    source: :concept

  def self.that_teaches!(concept)
    TaughtConcept.
      find_by!(concept: concept).
      exercise
  end

  def self.that_teaches(concept)
    that_teaches!(concept)
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
