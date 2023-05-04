class User::AcquiredBadge::Reveal
  include Mandate

  initialize_with :badge

  def call
    badge.update!(revealed: true)
    User::ResetCache.(badge.user)
  end
end
