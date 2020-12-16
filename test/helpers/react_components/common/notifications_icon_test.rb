require_relative "../react_component_test_case"

class CommonNotificationsIconTest < ReactComponentTestCase
  test "notifications icon rendered correctly" do
    user = create(:user)
    create(:notification, user: user, read_at: nil)

    assert_component ReactComponents::Common::NotificationsIcon.new(user),
      "common-notifications-icon",
      { count: 1 },
      fitted: true
  end
end
