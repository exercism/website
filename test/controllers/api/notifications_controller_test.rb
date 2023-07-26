require_relative './base_test_case'

class API::NotificationsControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_notifications_path
  guard_incorrect_token! :mark_batch_as_read_api_notifications_path, method: :patch
  guard_incorrect_token! :mark_batch_as_unread_api_notifications_path, method: :patch
  guard_incorrect_token! :mark_all_as_read_api_notifications_path, method: :patch

  ###
  # Index
  ###
  test "index retrieves notifications" do
    user = create :user
    setup_user(user)

    mentor = create :user
    notification = create :mentor_started_discussion_notification,
      user:,
      status: :unread,
      params: {
        discussion: create(:mentor_discussion, mentor:)
      }

    get api_notifications_path, headers: @headers, as: :json
    assert_response :ok

    expected = {
      results: [{
        uuid: notification.uuid,
        url: notification.url,
        text: notification.text,
        is_read: false,
        created_at: notification.created_at.iso8601,
        image_type: 'avatar',
        image_url: mentor.avatar_url,
        icon_filter: 'textColor6'
      }],
      meta: {
        current_page: 1,
        total_count: 1,
        total_pages: 1,
        unread_count: 1,
        links: {
          all: Exercism::Routes.notifications_url
        }
      }
    }.with_indifferent_access

    assert_equal expected, JSON.parse(response.body)
  end

  ###
  # Marking as read/unread
  ###
  test "mark_batch_as_read proxies" do
    user = create :user
    setup_user(user)

    uuid_1 = SecureRandom.uuid
    uuid_2 = SecureRandom.uuid

    User::Notification::MarkBatchAsRead.expects(:call).with(user, [uuid_1, uuid_2])

    patch mark_batch_as_read_api_notifications_path(uuids: [uuid_1, uuid_2]), headers: @headers, as: :json
    assert_response :ok

    assert_empty JSON.parse(response.body)
  end

  test "mark_batch_as_unread proxies" do
    user = create :user
    setup_user(user)

    uuid_1 = SecureRandom.uuid
    uuid_2 = SecureRandom.uuid

    User::Notification::MarkBatchAsUnread.expects(:call).with(user, [uuid_1, uuid_2])

    patch mark_batch_as_unread_api_notifications_path(uuids: [uuid_1, uuid_2]), headers: @headers, as: :json
    assert_response :ok

    assert_empty JSON.parse(response.body)
  end

  test "mark_all_as_read proxies" do
    user = create :user
    setup_user(user)

    User::Notification::MarkAllAsRead.expects(:call).with(user)

    patch mark_all_as_read_api_notifications_path, headers: @headers, as: :json
    assert_response :ok

    assert_equal AssembleNotificationsList.(user, {}).to_json, response.body
  end
end
