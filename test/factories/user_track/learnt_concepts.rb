FactoryBot.define do
  factory :user_track_learnt_concept, class: 'UserTrack::LearntConcept' do
    user_track
    concept { create :track_concept }
  end
end
