class Bootcamp::ExerciseConcept < ApplicationRecord
  self.table_name = "bootcamp_exercise_concepts"

  belongs_to :exercise, class_name: "Bootcamp::Exercise"
  belongs_to :concept, class_name: "Bootcamp::Concept"
end
