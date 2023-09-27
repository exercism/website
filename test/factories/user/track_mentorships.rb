FactoryBot.define do
  factory :user_track_mentorship, class: 'User::TrackMentorship' do
    user
    track

    trait :automator do
      automator { true }
    end
  end
end
