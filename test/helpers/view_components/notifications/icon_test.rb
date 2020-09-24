require_relative "../view_component_test_case"

class NotificationsIconTest < ViewComponentTestCase
  test "notifications icon rendered correctly" do
    user = create(:user)
    create(:notification, user: user, read_at: nil)

    assert_component_equal ViewComponents::Notifications::Icon.new(user).to_s,
                           { id: "notifications-icon", props: { count: 1 } }
  end
end
