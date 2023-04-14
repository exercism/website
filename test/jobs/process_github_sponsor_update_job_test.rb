require "test_helper"

class ProcessGithubSponsorUpdateJobTest < ActiveJob::TestCase
  test "updates first_donated_at to current time" do
    freeze_time do
      github_username = "foobar"
      user = create :user, github_username:, first_donated_at: nil

      perform_enqueued_jobs do
        ProcessGithubSponsorUpdateJob.perform_now(
          'created',
          github_username,
          'abd456',
          Time.utc(2022, 3, 6),
          true,
          300
        )
      end

      assert_equal Time.current, user.reload.first_donated_at
      assert user.donated?
    end
  end

  test "awards badge when created" do
    github_username = "foobar"
    user = create(:user, github_username:)

    perform_enqueued_jobs do
      ProcessGithubSponsorUpdateJob.perform_now(
        'created',
        github_username,
        'abd456',
        Time.utc(2022, 3, 6),
        true,
        300
      )
    end

    assert_includes user.reload.badges, Badges::SupporterBadge.first
  end

  test "noop when action is not created" do
    github_username = "foobar"
    create :user, github_username:

    AwardBadgeJob.expects(:perform_later).never

    refute ProcessGithubSponsorUpdateJob.perform_now(
      'something else',
      github_username,
      'abd456',
      Time.utc(2022, 3, 6),
      true,
      300
    )
  end

  test "nooop when user does not exist" do
    AwardBadgeJob.expects(:perform_later).never

    refute ProcessGithubSponsorUpdateJob.perform_now(
      'something else',
      "foobar",
      'abd456',
      Time.utc(2022, 3, 6),
      true,
      300
    )
  end
end
