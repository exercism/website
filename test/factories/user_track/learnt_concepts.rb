FactoryBot.define do
  factory :user_track_learnt_concept, class: 'UserTrack::LearntConcept' do
    user_track
    track_concept
  end
end
