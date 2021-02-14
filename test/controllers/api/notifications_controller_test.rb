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

    expected = {
      results: [{
        id: notification.uuid,
        url: notification.url,
        text: notification.text,
        is_read: false,
        created_at: notification.created_at.iso8601,
        image_type: 'avatar',
        image_url: mentor.avatar_url
      }],
      meta: {
        current_page: 1, total_count: 1, total_pages: 1, unread_count: 1
      },
      unrevealed_badges: { badges: [], links: { badges: Exercism::Routes.badges_journey_url } }
    }.with_indifferent_access

    assert_equal expected, JSON.parse(response.body)
  end
  test "index with unrevealed_badges" do
    user = create :user
    setup_user(user)

    badge = create :rookie_badge
    acquired_badge = create :user_acquired_badge, revealed: false, badge: badge, user: user

    get api_notifications_path, headers: @headers, as: :json
    assert_response 200

    expected = {
      results: [],
      meta: { current_page: 1, total_count: 0, total_pages: 0, unread_count: 0 },
      unrevealed_badges: {
        badges: [{
          id: acquired_badge.uuid,
          revealed: false,
          unlocked_at: acquired_badge.created_at.iso8601,
          name: "Rookie",
          description: "Submitted an exercise",
          rarity: 'common',
          icon_name: 'editor'
        }],
        links: { badges: Exercism::Routes.badges_journey_url }
      }
    }.with_indifferent_access

    assert_equal expected, JSON.parse(response.body)
  end
end
