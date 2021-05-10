class SerializeUserAcquiredBadge
  include Mandate

  initialize_with :acquired_badge

  def call
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
