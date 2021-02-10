require_relative './base_test_case'

class API::NotificationsControllerTest < API::BaseTestCase
  ###
  # Index
  ###
  test "index should return 401 with incorrect token" do
    get api_notifications_path, as: :json

    assert_response 401
    expected = { error: {
      type: "invalid_auth_token",
      message: I18n.t('api.errors.invalid_auth_token')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "index retrieves notifications" do
    user = create :user
    setup_user(user)

    notification = create :notification, user: user

    get api_notifications_path, headers: @headers, as: :json
    assert_response 200

    # TODO: Check JSON
    expected = {
      results: [{
        id: notification.id,
        text: notification.text,
        read: false,
        url: "/"
      }],
      meta: {
        current_page: 1, total_count: 1, total_pages: 1
      }
    }.with_indifferent_access

    assert_equal expected, JSON.parse(response.body)
  end
end
