require "application_system_test_case"

module Components
  class EditorTest < ApplicationSystemTestCase
    test "user submits code and tests pass" do
      create(:concept_solution)

      visit test_components_editor_path
      fill_in "Code", with: "Test"
      click_on "Submit"
      2.times { wait_for_websockets }
      click_on "Stub result"

      assert_text "Status: pass"
      assert_text "name: test_a_name_given, status: pass, output: Hello"
    end
  end
end
