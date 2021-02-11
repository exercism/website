require_relative './base_test_case'

class API::NotificationsControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_notifications_path
  guard_incorrect_token! :api_solution_iterations_path, args: 1, method: :post

  ###
  # Index
  ###
  test "index retrieves notifications" do
    user = create :user
    setup_user(user)

    mentor = create :user
    notification = create :mentor_started_discussion_notification,
      user: user,
      params: {
        discussion: create(:solution_mentor_discussion, mentor: mentor)
      }

    get api_notifications_path, headers: @headers, as: :json
    assert_response 200

    # TODO: Check JSON
    expected = {
      results: [{
        id: notification.id,
        url: notification.url,
        text: notification.text,
        read: false,
        created_at: notification.created_at.iso8601,
        image_type: 'avatar',
        image_url: mentor.avatar_url
      }],
      meta: {
        current_page: 1, total_count: 1, total_pages: 1
      }
    }.with_indifferent_access

    assert_equal expected, JSON.parse(response.body)
  end
end
