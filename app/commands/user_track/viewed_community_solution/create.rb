class UserTrack::ViewedCommunitySolution::Create
  include Mandate

  initialize_with :user, :track, :solution

  def call
    return if solution.user_id == user.id

    ::UserTrack::ViewedCommunitySolution.create_or_find_by!(user:, track:, solution:).tap do
      AwardTrophyJob.perform_later(user, track, :read_fifty_community_solutions)
    end
  end
end
