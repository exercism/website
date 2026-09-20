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

  test "becomes attendee and subscribes to onboarding emails if paid email" do
    enrollment = create :course_enrollment, :coding_fundamentals, :paid
    user = create :user, email: enrollment.email

    User::Bootstrap.(user)
    assert_equal user.id, enrollment.reload.user_id
    assert user.reload.bootcamp_attendee?
  end

  test "does not becomes attendee if not paid email" do
    enrollment = create :course_enrollment, :coding_fundamentals
    user = create :user, email: enrollment.email

    User::Bootstrap.(user)
    assert_equal user.id, enrollment.reload.user_id
    refute user.reload.bootcamp_attendee?
  end

  test "becomes attendee and subscribes to onboarding emails if paid access code" do
    enrollment = create :course_enrollment, :coding_fundamentals, :paid
    user = create :user

    User::Bootstrap.(user, course_access_code: enrollment.access_code)
    assert_equal user.id, enrollment.reload.user_id
    assert user.reload.bootcamp_attendee?
  end

  test "does not becomes attendee if not paid access code" do
    enrollment = create :course_enrollment, access_code: SecureRandom.hex(8)
    user = create :user

    User::Bootstrap.(user, course_access_code: enrollment.access_code)
    refute user.reload.bootcamp_attendee?
    assert_equal user.id, enrollment.reload.user_id
  end

  test "finds paid bootcamp data first" do
    email = "something@someone.com"
    create(:course_enrollment, email:)
    enrollment = create :course_enrollment, email:, paid_at: Time.current
    create(:course_enrollment, email:)
    user = create(:user, email:)

    User::Bootstrap.(user, course_access_code: enrollment.access_code)
    assert user.reload.bootcamp_attendee?
    assert_equal user.id, enrollment.reload.user_id
  end

  test "does not link with nuil access code" do
    # Create an enrollment without an access code
    enrollment = create :course_enrollment, paid_at: Time.current, access_code: nil
    user = create(:user)

    User::Bootstrap.(user, course_access_code: nil)
    refute user.reload.bootcamp_attendee?
    refute_equal user.id, enrollment.reload.user_id
  end

  test "does not link with blank access code" do
    # Create an enrollment without an access code
    enrollment = create :course_enrollment, paid_at: Time.current, access_code: ""
    user = create(:user)

    User::Bootstrap.(user, course_access_code: "")
    refute user.reload.bootcamp_attendee?
    refute_equal user.id, enrollment.reload.user_id
  end

  test "seeds the locale from the page the visitor signed up on" do
    user = create :user

    User::Bootstrap.(user, locale: "hu", accept_language: "en")

    assert_equal "hu", user.reload.data.locale
  end

  test "seeds the locale from accept-language on a naked page" do
    user = create :user

    User::Bootstrap.(user, locale: nil, accept_language: "hu,en;q=0.5")

    assert_equal "hu", user.reload.data.locale
  end

  test "the default locale in the path is not a signal" do
    user = create :user

    User::Bootstrap.(user, locale: "en", accept_language: "hu")

    assert_equal "hu", user.reload.data.locale
  end

  test "an unsupported accept-language seeds nothing" do
    user = create :user

    User::Bootstrap.(user, accept_language: "nl,de;q=0.8")

    assert_nil user.reload.data.locale
  end

  test "an existing locale is never overwritten" do
    user = create :user
    user.data.update!(locale: "en")

    User::Bootstrap.(user, accept_language: "hu")

    assert_equal "en", user.reload.data.locale
  end
end
