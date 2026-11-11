# Records that a signed-in user visited the site today, and sends
# site_visited to PostHog once per user per UTC day.
class User::TrackSiteVisit
  include Mandate

  initialize_with :user

  def call
    # This runs on every signed-in HTML request, so check memory first.
    return if user.last_visited_on == today
    return unless claim_today!

    Analytics::TrackEvent.defer(user, "site_visited")
  end

  private
  # Two concurrent requests can both pass the check above, so today is
  # claimed atomically in SQL. Only the request that changes the row sends
  # the event.
  def claim_today!
    User::Data.where(user_id: user.id).
      where("last_visited_on IS NULL OR last_visited_on < ?", today).
      update_all(last_visited_on: today, updated_at: Time.current).
      positive?
  end

  # PostHog buckets days in UTC. The app's time zone is also UTC, but this
  # uses the UTC date explicitly so the boundary stays the same if a request
  # ever runs in another zone.
  memoize
  def today = Time.current.utc.to_date
end
