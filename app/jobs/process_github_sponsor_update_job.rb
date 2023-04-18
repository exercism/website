class ProcessGithubSponsorUpdateJob < ApplicationJob
  queue_as :default

  def perform(action, _gh_username, _node_id, _privacy_level, _is_one_time, _monthly_price_in_cents)
    # case action
    # when 'cancelled'
    # when 'created'
    # when 'edited'
    # when 'tier_changed'
    # end
  end

  private
  memoize
  def user = User.find_by(github_username: gh_username)
end
