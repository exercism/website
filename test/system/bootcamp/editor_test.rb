require "application_system_test_case"

module Bootcamp
  class EditorTest < ApplicationSystemTestCase
    test "things render" do
      user = create(:user, bootcamp_attendee: true)
      exercise = create :bootcamp_exercise, :penguin

      use_capybara_host do
        sign_in!(user)
        visit bootcamp_project_exercise_url(exercise.project, exercise)

        assert_selector("#bootcamp-cm-editor")
        assert_selector("[data-ci='check-scenarios-button']")
        assert_selector("[data-ci='control-buttons']")
        assert_selector("[data-ci='task-preview']")
        refute_selector("[data-ci='inspected-test-result-view']")
        assert_selector(".page-header")
        assert_selector(".page-body-rhs")
        assert_selector(".scenario-rhs")
        assert_text "This is fun!"
      end
    end
  end
end
