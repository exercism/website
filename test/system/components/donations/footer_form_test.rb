require "application_system_test_case"

module Components
  module Donations
    class FooterFormTest < ApplicationSystemTestCase
      test "icon renders correctly" do
        visit test_components_donations_footer_form_path

        assert_selector '.c-icon'
      end
    end
  end
end
