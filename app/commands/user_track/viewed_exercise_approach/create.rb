class UserTrack::ViewedExerciseApproach::Create
  include Mandate

  initialize_with :user, :track, :approach

  def call
    ::UserTrack::ViewedExerciseApproach.create_or_find_by!(user:, track:, approach:)
  end
end
