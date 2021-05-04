require "application_system_test_case"

module Components
  module Common
    class IntroducerTest < ApplicationSystemTestCase
      test "hides introducer upon closing" do
        sign_in!
        visit test_components_common_introducer_path
        click_on "Permanently hide this introducer"

        assert_no_css ".c-introducer"

        # Reload page
        visit test_components_common_introducer_path
        assert_no_css ".c-introducer"
      end

      test "does not show hide button for logged out" do
        selector = ".c-introducer button"
        visit test_components_common_introducer_path
        assert_no_css selector

        sign_in!
        visit test_components_common_introducer_path
        assert_css selector
      end
    end
  end
end
