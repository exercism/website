require "test_helper"

class ProcessGithubSponsorUpdateJobTest < ActiveJob::TestCase
  test "processes 'cancelled' action" do
    github_username = 'jane'
    node_id = 'abdq313'
    privacy_level = 'public'
    is_one_time = true
    monthly_price_in_cents = 300
    user = create(:user, github_username:)

    Donations::Github::Sponsorship::HandleCancelled.expects(:call).
      with(user, node_id, privacy_level, is_one_time, monthly_price_in_cents).
      once

    ProcessGithubSponsorUpdateJob.perform_now(
      'cancelled', github_username, node_id, privacy_level, is_one_time, monthly_price_in_cents
    )
  end

  test "processes 'created' action" do
    github_username = 'jane'
    node_id = 'abdq313'
    privacy_level = 'public'
    is_one_time = true
    monthly_price_in_cents = 300
    user = create(:user, github_username:)

    Donations::Github::Sponsorship::HandleCreated.expects(:call).
      with(user, node_id, privacy_level, is_one_time, monthly_price_in_cents).
      once

    ProcessGithubSponsorUpdateJob.perform_now(
      'created', github_username, node_id, privacy_level, is_one_time, monthly_price_in_cents
    )
  end

  test "processes 'edited' action" do
    github_username = 'jane'
    node_id = 'abdq313'
    privacy_level = 'public'
    is_one_time = true
    monthly_price_in_cents = 300
    user = create(:user, github_username:)

    Donations::Github::Sponsorship::HandleEdited.expects(:call).
      with(user, node_id, privacy_level, is_one_time, monthly_price_in_cents).
      once

    ProcessGithubSponsorUpdateJob.perform_now(
      'edited', github_username, node_id, privacy_level, is_one_time, monthly_price_in_cents
    )
  end

  test "processes 'tier_changed' action" do
    github_username = 'jane'
    node_id = 'abdq313'
    privacy_level = 'public'
    is_one_time = true
    monthly_price_in_cents = 300
    user = create(:user, github_username:)

    Donations::Github::Sponsorship::HandleTierChanged.expects(:call).
      with(user, node_id, privacy_level, is_one_time, monthly_price_in_cents).
      once

    ProcessGithubSponsorUpdateJob.perform_now(
      'tier_changed', github_username, node_id, privacy_level, is_one_time, monthly_price_in_cents
    )
  end

  test "noop when user does not exist" do
    github_username = 'jane'
    node_id = 'abdq313'
    privacy_level = 'public'
    is_one_time = true
    monthly_price_in_cents = 300

    Donations::Github::Sponsorship::HandleCancelled.expects(:call).never
    Donations::Github::Sponsorship::HandleCreated.expects(:call).never
    Donations::Github::Sponsorship::HandleEdited.expects(:call).never
    Donations::Github::Sponsorship::HandleTierChanged.expects(:call).never

    ProcessGithubSponsorUpdateJob.perform_now(
      'cancelled', github_username, node_id, privacy_level, is_one_time, monthly_price_in_cents
    )
  end
end
