require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Components
  module Student
    class OpenEditorButtonTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "starts exercise" do
        track = create :track
        exercise = create :concept_exercise, track: track
        user = create :user
        create :user_track, user: user, track: track
        create :hello_world_solution, :completed, track: track, user: user

        use_capybara_host do
          sign_in!(user)

          visit track_exercise_url(track, exercise)
          within(".navbar") { click_on "Start in editor" }

          assert_page "editor"
          assert Solution.for(user, exercise)
        end
      end

      test "views completed exercise" do
        track = create :track
        exercise = create :concept_exercise, track: track
        user = create :user
        create :user_track, user: user, track: track
        solution = create :concept_solution, exercise: exercise, user: user, status: :completed, completed_at: 1.day.ago
        submission = create :submission, solution: solution, tests_status: :passed
        create :iteration, solution: solution, submission: submission

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_url(track, exercise)
          within(".navbar") { click_on "Open editor" }

          assert_page "editor"
        end
      end

      test "views published exercise" do
        track = create :track
        exercise = create :concept_exercise, track: track
        user = create :user
        create :user_track, user: user, track: track
        solution = create :concept_solution, exercise: exercise, user: user, status: :published, published_at: 1.day.ago
        submission = create :submission, solution: solution, tests_status: :passed
        create :iteration, solution: solution, submission: submission

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_url(track, exercise)
          within(".navbar") { click_on "Open editor" }

          assert_page "editor"
        end
      end

      test "continues an exercise" do
        track = create :track
        exercise = create :concept_exercise, track: track
        user = create :user
        create :user_track, user: user, track: track
        solution = create :concept_solution, exercise: exercise, user: user
        submission = create :submission, solution: solution, tests_status: :passed
        create :iteration, solution: solution, submission: submission

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_url(track, exercise)
          within(".navbar") { click_on "Continue in editor" }

          assert_page "editor"
        end
      end

      test "views locked exercise" do
        track = create :track
        exercise = create :concept_exercise, track: track
        exercise.prerequisites << create(:track_concept)
        user = create :user
        create :user_track, user: user, track: track

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_url(track, exercise)

          within(".navbar") do
            assert_text "Open editor"
            assert_css ".c-combo-button.--disabled"
          end
        end
      end

      test "shows download command" do
        track = create :track
        exercise = create :concept_exercise, track: track
        user = create :user
        create :user_track, user: user, track: track

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_url(track, exercise)
          within(".navbar") { find(".--dropdown-segment").click }

          assert_text "exercism download"
        end
      end
    end
  end
end
