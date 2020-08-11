class ConceptExercise < Exercise
  # TODO: Add these
  #  has_many :exercise_concepts, class_name: "Exercise::Prerequisite", dependent: :destroy
  #  has_many :concepts, through: :exercise_concepts, source: :track_concept
end
