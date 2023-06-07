class User::AcquiredBadge::Reveal
  include Mandate

  initialize_with :badge

  def call
    return if badge.revealed?

    badge.update!(revealed: true)
    User::ResetCache.defer(badge.user, :has_unrevealed_badges?)
  end
end
