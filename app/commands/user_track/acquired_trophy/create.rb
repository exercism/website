class UserTrack::AcquiredTrophy::Create
  include Mandate

  initialize_with :user, :track, :category, :slug, send_email: true

  def call
    # Check to see if it exists already before doing any other expensive things
    acquired_trophy = UserTrack::AcquiredTrophy.find_by(user:, trophy:, track:)
    return acquired_trophy if acquired_trophy

    # Check if the trophy should be awarded. Raise an exception if not
    raise TrophyCriteriaNotFulfilledError unless trophy.award?(user, track)

    # Build the trophy
    begin
      UserTrack::AcquiredTrophy.create!(
        user:,
        track:,
        trophy:
      ).tap do |user_track_acquired_trophy|
        if trophy.send_email_on_acquisition? && send_email
          User::Notification::CreateEmailOnly.(user, :acquired_trophy,
            user_track_acquired_trophy:)
        end
        User::Notification::Create.(user, trophy.notification_key) if trophy.notification_key.present?
      end

    # Guard against the race condition and return the trophy if it's been
    # created in parallel to this command
    rescue ActiveRecord::RecordNotUnique
      User::AcquiredTrophy.find_by!(
        user:,
        trophy:
      )
    end
  end

  private
  memoize
  def trophy = Track::Trophy.lookup!(category, slug)
end
