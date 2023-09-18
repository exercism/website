FactoryBot.define do
  factory :user_track_viewed_community_solution, class: 'UserTrack::ViewedCommunitySolution' do
    track do
      Track.find_by(slug: 'ruby') || build(:track, slug: 'ruby')
    end
    user
    solution { create :practice_solution, user:, track: }
  end
end
