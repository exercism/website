class PracticeExercise < Exercise
  has_many :exercise_practiced_concepts,
    class_name: "Exercise::PracticedConcept",
    foreign_key: :exercise_id,
    inverse_of: :exercise,
    dependent: :destroy

  has_many :practiced_concepts,
    through: :exercise_practiced_concepts,
    source: :concept

  def self.with_prerequisite(concept)
    joins(:exercise_prerequisites).
      where('exercise_prerequisites.track_concept_id': concept)
  end

  def self.that_practice(concept)
    joins(:exercise_practiced_concepts).
      where('exercise_practiced_concepts.track_concept_id': concept)
  end
end
