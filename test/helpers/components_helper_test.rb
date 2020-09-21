require "test_helper"

class ComponentsHelperTest < ActionView::TestCase
  include ComponentsHelper

  test "#notification_icon passes the correct parameters" do
    user = create(:user)
    create(:notification, user: user, read_at: nil)
    create(:notification, user: user, read_at: 1.day.ago)

    assert_component_equal notification_icon(user), { id: "notification-icon", props: { count: 1 } }
  end

  private
  def assert_component_equal(component, params)
    assert_dom_equal(
      %(<div data-react-#{params[:id]}="true" data-react-data=#{params[:props].to_json} />),
      component
    )
  end
end
