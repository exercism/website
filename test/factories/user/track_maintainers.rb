FactoryBot.define do
  factory :user_track_maintainer, class: 'User::TrackMaintainer' do
    user
    track
  end
end
