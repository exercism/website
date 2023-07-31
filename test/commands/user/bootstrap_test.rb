require "test_helper"

class User::BootstrapTest < ActiveSupport::TestCase
  test "creates auth_token" do
    user = create :user
    refute user.auth_tokens.present?

    User::Bootstrap.(user)
    assert user.auth_tokens.present?
  end

  test "awards member badge" do
    user = create :user
    refute user.badges.present?

    User::Bootstrap.(user)
    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::MemberBadge
  end

  test "adds metric" do
    user = create :user

    User::Bootstrap.(user)
    perform_enqueued_jobs

    assert_equal 1, Metric.count
    metric = Metric.last
    assert_instance_of Metrics::SignUpMetric, metric
    assert_equal user.created_at, metric.occurred_at
    assert_equal user, metric.user
  end

  test "email verified for new user" do
    user = create :user

    User::VerifyEmail.expects(:defer).with(user).once
    User::Bootstrap.(user)
  end
end
