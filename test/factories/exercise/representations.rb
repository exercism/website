FactoryBot.define do
  factory :exercise_representation, class: 'Exercise::Representation' do
    exercise { create :concept_exercise }
    exercise_version { 1 }
    representation { "(some(ast))" }
  end
end
