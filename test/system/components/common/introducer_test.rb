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
    end
  end
end
