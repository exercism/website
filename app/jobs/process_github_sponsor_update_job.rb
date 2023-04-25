class ProcessGithubSponsorUpdateJob < ApplicationJob
  queue_as :default

  def perform(action, gh_username, node_id, is_one_time, monthly_price_in_cents)
    user = User.find_by(github_username: gh_username)
    return unless user

    case action
    when 'cancelled'
      Donations::Github::Sponsorship::HandleCancelled.(user, node_id, is_one_time, monthly_price_in_cents)
    when 'created'
      Donations::Github::Sponsorship::HandleCreated.(user, node_id, is_one_time, monthly_price_in_cents)
    when 'tier_changed'
      Donations::Github::Sponsorship::HandleTierChanged.(user, node_id, is_one_time, monthly_price_in_cents)
    end
  end
end
