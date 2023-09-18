FactoryBot.define do
  factory :exercise_representation, class: 'Exercise::Representation' do
    exercise { source_submission.exercise }
    track { exercise.track }
    source_submission { create :submission }
    mapping { { foo: 'bar' } }
    uuid { SecureRandom.uuid }
    ast { SecureRandom.uuid }

    trait :with_feedback do
      feedback_markdown { "foo" }
      feedback_author { create(:user) }
      feedback_type { :actionable }
    end
  end
end
