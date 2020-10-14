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

    test "user submits code and tests fail" do
      create(:concept_solution)

      visit test_components_editor_path
      fill_in "Code", with: "Test"
      select "Fail", from: "Test status"
      click_on "Submit"
      2.times { wait_for_websockets }
      click_on "Stub result"

      assert_text "Status: fail"
      assert_text "name: test_no_name_given, status: fail"
    end

    test "user submits code and errors" do
      create(:concept_solution)

      visit test_components_editor_path
      fill_in "Code", with: "Test"
      select "Error", from: "Test status"
      click_on "Submit"
      2.times { wait_for_websockets }
      click_on "Stub result"

      assert_text "Status: error"
      assert_text "Undefined local variable"
    end

    test "user submits code and an ops error happens" do
      create(:concept_solution)

      visit test_components_editor_path
      fill_in "Code", with: "Test"
      select "Ops error", from: "Test status"
      click_on "Submit"
      2.times { wait_for_websockets }
      click_on "Stub result"

      assert_text "Status: ops_error"
      assert_text "Can't run the tests"
    end
  end
end
