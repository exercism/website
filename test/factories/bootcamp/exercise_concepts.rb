FactoryBot.define do
  factory :bootcamp_exercise_concept, class: "Bootcamp::ExerciseConcept" do
    exercise { create(:bootcamp_exercise) }
    concept { create(:bootcamp_concept) }
  end
end
