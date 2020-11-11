require "test_helper"

class ReactComponentTestCase < ActionView::TestCase
  def assert_component(component, id, data)
    assert_dom_equal(
      %(
       <div
         data-react-#{id}="true"
         data-react-data="#{ERB::Util.unwrapped_html_escape(data.to_json)}"
        />
      ).strip,
      component.to_s
    )
  end
end
