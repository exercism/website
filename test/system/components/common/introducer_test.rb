require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Components
  module Common
    class IntroducerTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "hides introducer upon closing" do
        use_capybara_host do
          sign_in!
          visit test_components_common_introducer_path
          click_on "Permanently hide this introducer"

          assert_css ".c-introducer", visible: false

          # Reload page
          visit test_components_common_introducer_path
          assert_no_css ".c-introducer"
        end
      end

      test "does not show hide button for logged out" do
        use_capybara_host do
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
end
