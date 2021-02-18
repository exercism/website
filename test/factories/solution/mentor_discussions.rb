FactoryBot.define do
  factory :solution_mentor_discussion, class: 'Solution::MentorDiscussion' do
    mentor { create :user }
    request { create :solution_mentor_request }
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
