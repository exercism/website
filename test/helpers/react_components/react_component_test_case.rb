require "test_helper"

class ReactComponentTestCase < ActionView::TestCase
  def assert_component(component, id, data, fitted: false)
    css_classes = ["c-react-component"]
    css_classes << "c-react-wrapper-#{id}"
    css_classes << '--fitted' if fitted
    assert_dom_equal(
      %(
       <div
         class="#{css_classes.join(' ')}"
         data-react-id="#{id}"
         data-react-data="#{ERB::Util.unwrapped_html_escape(data.to_json)}"
         data-react-hydrate="false"
       ></div>
      ).split("\n").map(&:strip).join(" ").strip,
      component.to_s
    )
  end
end
