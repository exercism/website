class User::RegisterAsDonor
  include Mandate

  initialize_with :user

  def call
    user.update(donated: true)
    AwardBadgeJob.perform_later(user, :supporter)
  end
end
