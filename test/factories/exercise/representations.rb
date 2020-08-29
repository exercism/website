FactoryBot.define do
  factory :exercise_representation, class: 'Exercise::Representation' do
    exercise { create :concept_exercise }
    source_iteration { create :iteration }
    mapping { { foo: 'bar' } }
    exercise_version { 1 }
    ast { SecureRandom.uuid }
    ast_digest { SecureRandom.uuid }
  end
end
