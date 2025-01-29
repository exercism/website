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

    test "shows all scenario previews" do
      user = create(:user, bootcamp_attendee: true)
      exercise = create :bootcamp_exercise, :even_or_odd

      use_capybara_host do
        sign_in!(user)
        visit bootcamp_project_exercise_url(exercise.project, exercise)

        assert_selector("[data-ci='task-preview']")
        assert_selector("[data-ci='preview-scenario-button']", count: 5)
        assert_text "Number 14"
        find("[data-ci='preview-scenario-button']:nth-of-type(2)").click
        assert_text "Number 28"
      end
    end

    test "sets up exercise view correctly" do
      user = create(:user, bootcamp_attendee: true)
      exercise = create :bootcamp_exercise, :manual_solve

      use_capybara_host do
        sign_in!(user)
        visit bootcamp_project_exercise_url(exercise.project, exercise)

        assert_selector("[data-ci='task-preview']")
        assert_text "Guide person to the end of the maze"
        assert_text "Your job is to reach the goal"
        assert_selector("[data-ci='preview-scenario-button']", count: 1)
        assert_selector(".cell", count: 49)
        assert_selector(".character")
      end
    end
  end
end
