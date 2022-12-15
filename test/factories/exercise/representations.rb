FactoryBot.define do
  factory :exercise_representation, class: 'Exercise::Representation' do
    track do
      Track.find_by(slug: 'ruby') || create(:track, slug: 'ruby')
    end
    exercise { create :concept_exercise, track: }
    source_submission { create :submission, track: }
    mapping { { foo: 'bar' } }
    uuid { SecureRandom.uuid }
    ast { SecureRandom.uuid }
    ast_digest { SecureRandom.uuid }

    trait :with_feedback do
      feedback_markdown { "foo" }
      feedback_author { create(:user) }
      feedback_type { :actionable }
    end
  end
end
