class ProcessGithubSponsorUpdateJob < ApplicationJob
  queue_as :default

  def perform(action, gh_username, node_id, is_one_time, monthly_price_in_cents)
    user = User.with_data.find_by(data: { github_username: gh_username })
    return unless user

    case action
    when 'cancelled'
      Payments::Github::Sponsorship::HandleCancelled.(user, node_id, is_one_time)
    when 'created'
      Payments::Github::Sponsorship::HandleCreated.(user, node_id, is_one_time, monthly_price_in_cents)
    when 'tier_changed'
      Payments::Github::Sponsorship::HandleTierChanged.(user, node_id, is_one_time, monthly_price_in_cents)
    end
  end
end
