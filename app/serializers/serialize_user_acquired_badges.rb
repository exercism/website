class SerializeUserAcquiredBadges
  include Mandate

  initialize_with :acquired_badges

  def call
    acquired_badges.includes(:badge).map { |ab| SerializeUserAcquiredBadge.(ab) }
  end
end
