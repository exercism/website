require "application_system_test_case"

module Bootcamp
  class EditorTest < ApplicationSystemTestCase
    test "shows to basic user" do
      user = create(:user, bootcamp_attendee: true)
      exercise = create :bootcamp_exercise, :penguin

      use_capybara_host do
        sign_in!(user)
        visit bootcamp_project_exercise_url(exercise.project, exercise)

        assert_text "Welcome to the Exercism Bootcamp!"
      end
    end
  end
end
