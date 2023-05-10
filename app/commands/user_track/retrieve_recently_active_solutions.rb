class UserTrack::RetrieveRecentlyActiveSolutions
  include Mandate

  initialize_with :user_track
  delegate :user, :track, to: :user_track

  def call
    # This gets the activities for the right user/track,
    # but only selects one per grouping_key, where the grouping_key
    # is something like Exercise#5. So if someone has started the exercise and
    # submitted two iterations, this will only retrieve the latest activity
    # about the latest iteration. It achieves this by a Group/MAX(id) and then
    # an outer query to get the normal fields.
    solution_ids = User::Activity.
      where(user:, track:).
      group(:solution_id).
      order(id: :desc).
      select("solution_id, max(id) as id").
      limit(5).
      pluck(:solution_id)

    Solution.where(id: solution_ids).
      order(Arel.sql("FIND_IN_SET(id, '#{solution_ids.join(',')}')")).
      includes(
        :exercise, :track, :user,
        latest_iteration: [
          :exercise, :track,
          { submission: %i[
            analysis solution submission_representation
          ] }
        ]
      )
  end
end
