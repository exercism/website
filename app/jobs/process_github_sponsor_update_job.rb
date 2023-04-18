class ProcessGithubSponsorUpdateJob < ApplicationJob
  queue_as :default

  def perform(action, gh_username, _node_id, _privacy_level, _is_one_time, _monthly_price_in_cents)
    return unless action == 'created'

    user = User.find_by(github_username: gh_username)
    return unless user

    User::RegisterAsDonor.(user, Time.current)
  end
end
