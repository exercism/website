FactoryBot.define do
  factory :user_track_concept, class: 'UserTrack::Concept' do
    user_track
    track_concept
  end
end
