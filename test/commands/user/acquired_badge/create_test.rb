require "test_helper"

class User::AcquiredBadge::CreateTest < ActiveSupport::TestCase
  test "returns existing badge" do
    user = create :user
    badge = create :contributor_badge
    expected = create(:user_acquired_badge, user:, badge:)

    actual = User::AcquiredBadge::Create.(user, :contributor)
    assert_equal expected, actual
  end

  test "creates new badge" do
    user = create :user
    badge = create :contributor_badge
    Badges::ContributorBadge.any_instance.expects(:award_to?).with(user).returns(true)

    actual = User::AcquiredBadge::Create.(user, :contributor)
    assert_equal user, actual.user
    assert_equal badge, actual.badge
  end

  test "fails if criteria are not met" do
    user = create :user
    create :contributor_badge
    Badges::ContributorBadge.any_instance.expects(:award_to?).with(user).returns(false)

    assert_raises BadgeCriteriaNotFulfilledError do
      User::AcquiredBadge::Create.(user, :contributor, send_email: false)
    end
  end

  test "Creates notification if key is present" do
    user = create :user
    force_award!(user)

    create :contributor_badge
    notification_key = :some_key
    Badges::ContributorBadge.any_instance.stubs(notification_key:)
    User::Notification::Create.expects(:call).with(user, notification_key)

    User::AcquiredBadge::Create.(user, :contributor)
  end

  test "Does not create notification if key is not present" do
    user = create :user
    force_award!(user)

    create :contributor_badge
    notification_key = ""
    Badges::ContributorBadge.any_instance.stubs(notification_key:)
    User::Notification::Create.expects(:call).never

    User::AcquiredBadge::Create.(user, :contributor)
  end

  test "Sends email if send_email_on_acquisition" do
    user = create :user
    force_award!(user)

    create :contributor_badge
    Badges::ContributorBadge.any_instance.expects(:send_email_on_acquisition?).returns(true)
    User::Notification::CreateEmailOnly.expects(:call).with do |*params|
      assert_equal user, params[0]
      assert_equal :acquired_badge, params[1]
      assert_equal :user_acquired_badge, params[2].keys.first
      assert params[2].values.first.is_a?(User::AcquiredBadge)
    end

    User::AcquiredBadge::Create.(user, :contributor)
  end

  test "Does not send email if send_email_on_acquisition is false" do
    user = create :user
    force_award!(user)

    create :contributor_badge
    Badges::ContributorBadge.any_instance.expects(:send_email_on_acquisition?).returns(false)
    User::Notification::CreateEmailOnly.expects(:call).never

    User::AcquiredBadge::Create.(user, :contributor)
  end

  test "Does not send email if send_email_on_acquisition is true and send_email is false" do
    user = create :user
    force_award!(user)

    create :contributor_badge
    Badges::ContributorBadge.any_instance.expects(:send_email_on_acquisition?).returns(true)
    User::Notification::CreateEmailOnly.expects(:call).never

    User::AcquiredBadge::Create.(user, :contributor, send_email: false)
  end

  test "resets user cache" do
    user = create :user
    create :contributor_badge
    Badges::ContributorBadge.any_instance.expects(:award_to?).with(user).returns(true)

    assert_user_data_cache_reset(user, :has_unrevealed_badges?, true) do
      User::AcquiredBadge::Create.(user, :contributor)
    end
  end

  def force_award!(user)
    Badges::ContributorBadge.any_instance.expects(:award_to?).with(user).returns(true)
  end
end
