FactoryBot.define do
  factory :user_track_acquired_trophy, class: 'UserTrack::AcquiredTrophy' do
    track do
      Track.find_by(slug: 'ruby') || build(:track, slug: 'ruby')
    end
    trophy
    user
  end
end
