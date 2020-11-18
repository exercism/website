FactoryBot.define do
  factory :exercise_representation, class: 'Exercise::Representation' do
    exercise { create :concept_exercise }
    source_submission { create :submission }
    mapping { { foo: 'bar' } }
    ast { SecureRandom.uuid }
    ast_digest { SecureRandom.uuid }
  end
end
