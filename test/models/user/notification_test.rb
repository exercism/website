require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  test "statuses" do
    user = create :user
    pending = create :notification, user:, status: :pending
    unread = create :notification, user:, status: :unread
    read = create :notification, user:, status: :read

    assert pending.pending?
    assert unread.unread?
    assert read.read?

    assert_equal [pending], User::Notification.pending
    assert_equal [unread], User::Notification.unread
    assert_equal [read], User::Notification.read
    assert_equal [pending, unread], User::Notification.pending_or_unread
  end

  test "read!" do
    freeze_time do
      user = create :user
      notification = create :notification, user:, status: :unread
      refute notification.read?
      assert_empty user.notifications.read
      assert_equal [notification], user.notifications.unread

      notification.read!
      assert notification.read?
      assert_equal Time.current, notification.read_at
      assert_equal [notification], user.notifications.read
      assert_empty user.notifications.unread
    end
  end

  test "text is sanitized" do
    notification = User::Notification.new
    notification.define_singleton_method(:i18n_params) do
      { user: "<foo>d</foo>angerous" }
    end

    I18n.expects(:t).with(
      "notifications.notification.",
      user: "dangerous"
    ).returns("")

    notification.text
  end

  test "rendering_data" do
    mentor = create :user
    notification = create :mentor_started_discussion_notification,
      params: {
        discussion: create(:mentor_discussion, mentor:)
      }

    expected = {
      uuid: notification.uuid,
      url: notification.url,
      text: notification.text,
      is_read: false,
      created_at: notification.created_at.iso8601,
      image_type: 'avatar',
      image_url: mentor.avatar_url,
      icon_filter: "textColor6"
    }.with_indifferent_access

    assert_equal expected, notification.rendering_data
  end

  test "image_url for asset host that is domain" do
    Rails.application.config.action_controller.expects(:asset_host).returns('http://test.exercism.org').at_least_once
    user = create :user

    notification = User::Notifications::AddedToContributorsPageNotification.create!(user:)

    assert_equal "http://test.exercism.org/assets/icons/contributors-8873894d89a89d8a22512b9253d17a57b91df2d7.svg",
      notification.image_url
  end

  test "image_url for asset host that is path" do
    Rails.application.config.action_controller.expects(:asset_host).returns('/my-assets').at_least_once
    user = create :user

    notification = User::Notifications::AddedToContributorsPageNotification.create!(user:)

    assert_equal "/my-assets/assets/icons/contributors-8873894d89a89d8a22512b9253d17a57b91df2d7.svg",
      notification.image_url
  end
end
