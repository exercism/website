require "test_helper"

class ViewComponentTestCase < ActionView::TestCase
  def assert_component_equal(component, params)
    assert_dom_equal(
      %(<div data-react-#{params[:id]}="true" data-react-data=#{params[:props].to_json} />),
      component
    )
  end
end
