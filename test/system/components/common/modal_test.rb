require "application_system_test_case"

module Components
  module Common
    class ModalTest < ApplicationSystemTestCase
      test "user sees modal" do
        visit test_components_common_modal_path

        assert_selector "h1", text: "Hello"
      end
    end
  end
end
