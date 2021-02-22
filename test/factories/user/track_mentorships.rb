FactoryBot.define do
  factory :user_track_mentorship, class: 'User::TrackMentorship' do
    user
    track
  end
end
