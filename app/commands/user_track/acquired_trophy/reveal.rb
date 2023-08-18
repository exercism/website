class UserTrack::AcquiredTrophy::Reveal
  include Mandate

  initialize_with :acquired_trophy

  def call
    return if acquired_trophy.revealed?

    acquired_trophy.update!(revealed: true)
    notification&.read!
  end

  def notification
    User::Notifications::AcquiredTrophyNotification.pending_or_unread.where(
      user_id: acquired_trophy.user_id,
      track_id:
    ).find do |notification|
      notification.user_track_acquired_trophy.trophy_id == trophy_id
    end
  end

  delegate :trophy_id, :track_id, to: :acquired_trophy
end
