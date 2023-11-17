FactoryBot.define do
  factory :user_track_viewed_exercise_approach, class: 'UserTrack::ViewedExerciseApproach' do
    track do
      Track.find_by(slug: 'ruby') || build(:track, slug: 'ruby')
    end
    user
    approach { create :exercise_approach, track: }
  end
end
