class UserTrack::ViewedExerciseApproach::Create
  include Mandate

  initialize_with :user, :track, :approach

  def call
    ::UserTrack::ViewedExerciseApproach.create_or_find_by!(user:, track:, approach:).tap do
      AwardTrophyJob.perform_later(user, track, :read_five_approaches)
    end
  end
end
