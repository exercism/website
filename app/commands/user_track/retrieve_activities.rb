class UserTrack::RetrieveActivities
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
    group_filter = User::Activity.
      where(user: user, track: track).
      group(:grouping_key).
      order(id: :desc).
      select("grouping_key, max(id) as id").
      limit(5)

    User::Activity.from("(#{group_filter.to_sql}) as grouped_table").
      joins("INNER JOIN user_activities on user_activities.id = grouped_table.id").
      order(id: :desc)
  end
end
