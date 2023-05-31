require "test_helper"

class ProcessGithubSponsorUpdateJobTest < ActiveJob::TestCase
  test "processes 'cancelled' action" do
    github_username = 'jane'
    node_id = 'abdq313'
    is_one_time = true
    monthly_price_in_cents = 300
    user = create(:user, github_username:)

    Payments::Github::Sponsorship::HandleCancelled.expects(:call).
      with(user, node_id, is_one_time).
      once

    ProcessGithubSponsorUpdateJob.perform_now(
      'cancelled', github_username, node_id, is_one_time, monthly_price_in_cents
    )
  end

  test "processes 'created' action" do
    github_username = 'jane'
    node_id = 'abdq313'
    is_one_time = true
    monthly_price_in_cents = 300
    user = create(:user, github_username:)

    Payments::Github::Sponsorship::HandleCreated.expects(:call).
      with(user, node_id, is_one_time, monthly_price_in_cents).
      once

    ProcessGithubSponsorUpdateJob.perform_now(
      'created', github_username, node_id, is_one_time, monthly_price_in_cents
    )
  end

  test "processes 'tier_changed' action" do
    github_username = 'jane'
    node_id = 'abdq313'
    is_one_time = true
    monthly_price_in_cents = 300
    user = create(:user, github_username:)

    Payments::Github::Sponsorship::HandleTierChanged.expects(:call).
      with(user, node_id, is_one_time, monthly_price_in_cents).
      once

    ProcessGithubSponsorUpdateJob.perform_now(
      'tier_changed', github_username, node_id, is_one_time, monthly_price_in_cents
    )
  end

  test "noop when user does not exist" do
    github_username = 'jane'
    node_id = 'abdq313'
    is_one_time = true
    monthly_price_in_cents = 300

    Payments::Github::Sponsorship::HandleCancelled.expects(:call).never
    Payments::Github::Sponsorship::HandleCreated.expects(:call).never
    Payments::Github::Sponsorship::HandleTierChanged.expects(:call).never

    ProcessGithubSponsorUpdateJob.perform_now(
      'cancelled', github_username, node_id, is_one_time, monthly_price_in_cents
    )
  end
end
