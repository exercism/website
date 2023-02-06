FactoryBot.define do
  factory :user_track_mentorship, class: 'User::TrackMentorship' do
    user
    track

    trait :supermentor_frequency do
      num_finished_discussions { 100 }
    end
  end
end
