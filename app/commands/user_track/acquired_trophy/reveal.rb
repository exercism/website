class UserTrack::AcquiredTrophy::Reveal
  include Mandate

  initialize_with :trophy

  def call
    return if trophy.revealed?

    trophy.update!(revealed: true)
  end
end
