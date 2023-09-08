class UserTrack::Reset
  include Mandate

  initialize_with :user_track
  delegate :user, :track, to: :user_track

  def call
    # We need to get the published representation before we're updating the
    # solutions, as at that point the link will be gone
    published_exercise_representations = Exercise::Representation.where(
      id: user_track.solutions.select(:published_exercise_representation_id)
    ).to_a
    user_track.viewed_community_solutions.destroy_all
    user_track.solutions.update_all(%{
      user_id = #{User::GHOST_USER_ID},
      unique_key = UUID(),
      published_exercise_representation_id = NULL
    })
    user_track.update(
      anonymous_during_mentoring: false,
      last_touched_at: Time.current,
      objectives: nil
    )
    user_track.reset_summary!
    User::ReputationTokens::PublishedSolutionToken.where(user:, track:).destroy_all
    Solution::RemoveUserSolutionsForTrackFromSearchIndex.defer(user.id, track.id)
    published_exercise_representations.each do |representation|
      Exercise::Representation::UpdatePublishedSolutions.defer(representation, wait: 10.seconds)
    end
  end
end
