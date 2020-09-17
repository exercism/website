require_relative "./view_component_test_case"

class NotificationIconTest < ViewComponentTestCase
  test "#notification_icon passes the correct parameters" do
    user = create(:user)
    create(:notification, user: user, read_at: nil)

    assert_component_equal NotificationIcon.new.render(user), { id: "notification-icon", props: { count: 1 } }
  end
end
