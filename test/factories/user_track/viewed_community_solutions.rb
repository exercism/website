FactoryBot.define do
  factory :user_track_viewed_community_solution, class: 'UserTrack::ViewedCommunitySolution' do
    user_track
    solution { create :practice_solution }
  end
end
