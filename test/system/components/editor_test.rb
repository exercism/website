require "application_system_test_case"

module Components
  class EditorTest < ApplicationSystemTestCase
    test "user submits code and all tests pass" do
      create(:concept_solution)

      visit test_components_editor_path
      wait_for_websockets
      fill_in "Code", with: "Test"
      click_on "Submit"

      assert_text "Status: pass"
      assert_text "name: test_a_name_given, status: pass, output: Hello"
    end
  end
end
