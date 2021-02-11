class SerializeUserAcquiredBadges
  include Mandate

  initialize_with :acquired_badges

  def call
    acquired_badges.includes(:badge).
      map { |ab| serialize_badge(ab) }
  end

  private
  def serialize_badge(acquired_badge)
    badge = acquired_badge.badge

    {
      id: acquired_badge.uuid,
      revealed: acquired_badge.revealed?,
      unlocked_at: acquired_badge.created_at.iso8601,
      name: badge.name,
      description: badge.description,
      rarity: badge.rarity,
      icon_name: badge.icon # TODO: Change this to a URL
    }
  end
end
