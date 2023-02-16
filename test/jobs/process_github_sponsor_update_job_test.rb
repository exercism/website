require "test_helper"

class ProcessGithubSponsorUpdateJobTest < ActiveJob::TestCase
  test "awards badge when created" do
    github_username = "foobar"
    user = create :user, github_username: github_username

    AwardBadgeJob.expects(:perform_later).with(user, :supporter).once

    ProcessGithubSponsorUpdateJob.perform_now(
      'created',
      github_username
    )
  end

  test "nooop when action is not created" do
    github_username = "foobar"
    create :user, github_username:

    AwardBadgeJob.expects(:perform_later).never

    refute ProcessGithubSponsorUpdateJob.perform_now(
      'something else',
      github_username
    )
  end

  test "nooop when user does not exist" do
    AwardBadgeJob.expects(:perform_later).never

    refute ProcessGithubSponsorUpdateJob.perform_now(
      'something else',
      "foobar"
    )
  end
end
