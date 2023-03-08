class User::RegisterAsDonor
  include Mandate

  initialize_with :user, :first_donated_at

  def call
    user.update(first_donated_at:)
    AwardBadgeJob.perform_later(user, :supporter)
  end
end
