require "test_helper"

class ReactComponentTestCase < ActionView::TestCase
  def assert_component(component, id, data, fitted: false)
    assert_dom_equal(
      %(
       <div
         class="c-react-component #{'--fitted' if fitted}"
         data-react-#{id}="true"
         data-react-data="#{ERB::Util.unwrapped_html_escape(data.to_json)}"></div>
      ).split("\n").map(&:strip).join(" ").strip,
      component.to_s
    )
  end
end
