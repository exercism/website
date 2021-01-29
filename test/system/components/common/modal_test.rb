require "application_system_test_case"

module Components
  module Common
    class ModalTest < ApplicationSystemTestCase
      test "block: user sees modal" do
        visit block_test_components_common_modal_path

        assert_selector "h1", text: "I am some code in a block"
      end

      test "block: user closes modal" do
        visit block_test_components_common_modal_path

        click_on "Close"

        assert_no_selector "h1", text: "I am some code in a block"
      end

      test "template: user sees modal" do
        visit template_test_components_common_modal_path

        assert_selector "h1", text: "I am some code via a template and my name is iHiD"
      end

      test "template: user closes modal" do
        visit template_test_components_common_modal_path

        click_on "Close"

        assert_no_selector "h1", text: "I am some code via a template and my name is iHiD"
      end
    end
  end
end
