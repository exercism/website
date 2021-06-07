require_relative "../react_component_test_case"

module ReactComponents
  module Common
    class WalkthroughTest < ReactComponentTestCase
      test "renders temporary token when there is no user" do
        Git::WebsiteCopy.any_instance.stubs(:walkthrough).returns("[CONFIGURE_COMMAND]")

        component = ReactComponents::Common::Walkthrough.new(nil).to_s

        expected = {
          html: "exercism configure --token=[TOKEN]"
        }
        assert_component component, "common-walkthrough", expected
      end
    end
  end
end
