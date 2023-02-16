class ProcessGithubSponsorUpdateJob < ApplicationJob
  queue_as :default

  def perform(action, gh_username)
    return unless action == 'created'

    user = User.find_by(github_username: gh_username)
    return unless user

    AwardBadgeJob.perform_later(user, :supporter)
  end
end
