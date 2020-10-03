class ConceptExercise < Exercise
  # TODO: Add taught concepts here
  # has_many :exercise_concepts, class_name: "Exercise::Prerequisite", foreign_key: :exercise_id, dependent: :destroy
  # has_many :concepts, through: :exercise_concepts, source: :track_concept
end
