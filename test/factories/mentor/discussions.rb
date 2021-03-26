FactoryBot.define do
  factory :mentor_discussion, class: 'Mentor::Discussion' do
    mentor { create :user }
    request { create :mentor_request }
    solution { create :practice_solution, track: track }

    transient do
      track do
        Track.find_by(slug: 'ruby') || create(:track, slug: 'ruby')
      end
    end

    trait :requires_mentor_action do
      requires_mentor_action_since { Time.current }
    end
  end
end
