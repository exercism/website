class UserTrack::ViewedExerciseApproach::Create
  include Mandate

  initialize_with :user, :track, :exercise_approach

  def call
    ::UserTrack::ViewedExerciseApproach.create_or_find_by!(user:, track:, exercise_approach:)
  end
end
