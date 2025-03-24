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

  test "becomes attendee and subscribes to onboarding emails if paid email" do
    email = "#{SecureRandom.uuid}@test.com"
    ubd = create :user_bootcamp_data, email:, paid_at: Time.current
    user = create(:user, email:)

    # Always does this once by default anyway
    User::Bootcamp::SubscribeToOnboardingEmails.expects(:defer).with(ubd).twice

    User::Bootstrap.(user)
    assert user.reload.bootcamp_attendee?
    assert_equal user.id, ubd.reload.user_id
  end

  test "does not becomes attendee if not paid email" do
    email = "#{SecureRandom.uuid}@test.com"
    ubd = create(:user_bootcamp_data, email:)
    user = create(:user, email:)

    User::Bootcamp::SubscribeToOnboardingEmails.expects(:defer).with(ubd).twice

    User::Bootstrap.(user)
    refute user.reload.bootcamp_attendee?
    assert_equal user.id, ubd.reload.user_id
  end

  test "becomes attendee and subscribes to onboarding emails if paid access code" do
    enrollment = create :course_enrollment, :coding_fundamentals, :paid
    user = create :user, email: enrollment.email

    User::Bootstrap.(user, bootcamp_access_code: enrollment.access_code)
    assert_equal user.id, enrollment.reload.user_id
    assert user.reload.bootcamp_attendee?
  end

  test "does not becomes attendee if not paid access code" do
    ubd = create :user_bootcamp_data, access_code: SecureRandom.hex(8)
    user = create :user

    User::Bootcamp::SubscribeToOnboardingEmails.expects(:defer).with(ubd).twice

    User::Bootstrap.(user, bootcamp_access_code: ubd.access_code)
    refute user.reload.bootcamp_attendee?
    assert_equal user.id, ubd.reload.user_id
  end

  test "finds paid bootcamp data first" do
    email = "something@someone.com"
    create(:user_bootcamp_data, email:)
    ubd = create :user_bootcamp_data, email:, paid_at: Time.current
    create(:user_bootcamp_data, email:)
    user = create(:user, email:)

    # Always does this once by default anyway
    User::Bootcamp::SubscribeToOnboardingEmails.expects(:defer).with(ubd).twice

    User::Bootstrap.(user, bootcamp_access_code: ubd.access_code)
    assert user.reload.bootcamp_attendee?
    assert_equal user.id, ubd.reload.user_id
  end
end
