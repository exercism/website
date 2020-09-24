require "test_helper"

class ViewComponentTestCase < ActionView::TestCase
  def assert_component_equal(component, params)
    assert_dom_equal(
      %(
       <div
         data-react-#{params[:id]}="true"
         data-react-data="#{ERB::Util.unwrapped_html_escape(params[:props].to_json)}"
        />
      ).strip,
      component
    )
  end
end
