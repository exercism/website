require "application_system_test_case"
require_relative "../../../support/capybara_helpers"
require_relative "../../../support/markdown_editor_helpers"

module Flows
  module Mentor
    class SupermentorGivesFeedbackToRepresentationTest < ApplicationSystemTestCase
      include CapybaraHelpers
      include MarkdownEditorHelpers

      test "mentor sees only supermentor frequency tracks on need feedback page" do
        mentor = create :user, :supermentor

        csharp = create :track, slug: :csharp, title: 'C#'
        ruby = create :track, slug: :ruby, title: 'Ruby'
        javascript = create :track, slug: :javascript, title: 'JavaScript'

        csharp_exercise = create :practice_exercise, track: csharp
        ruby_exercise = create :practice_exercise, track: ruby
        create :practice_exercise, track: javascript

        create :exercise_representation, exercise: csharp_exercise, feedback_type: nil, num_submissions: 3
        create :exercise_representation, exercise: ruby_exercise, feedback_type: nil, num_submissions: 2

        create :user_track_mentorship, :supermentor_frequency, user: mentor, track: csharp
        create :user_track_mentorship, user: mentor, track: javascript
        create :user_track_mentorship, :supermentor_frequency, user: mentor, track: ruby

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_automation_index_path

          within(".automation-header") do
            click_on "C#"

            assert_text csharp.title
            assert_text ruby.title
            refute_text javascript.title
          end
        end
      end

      test "mentor changes track on need feedback page" do
        mentor = create :user, :supermentor

        csharp = create :track, slug: :csharp, title: 'C#'
        ruby = create :track, slug: :ruby, title: 'Ruby'

        csharp_exercise = create :practice_exercise, :random_slug, track: csharp
        ruby_exercise = create :practice_exercise, :random_slug, track: ruby

        create :exercise_representation, exercise: csharp_exercise, feedback_type: nil, num_submissions: 3
        create :exercise_representation, exercise: ruby_exercise, feedback_type: nil, num_submissions: 2

        create :user_track_mentorship, :supermentor_frequency, user: mentor, track: csharp
        create :user_track_mentorship, :supermentor_frequency, user: mentor, track: ruby

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_automation_index_path

          assert_text csharp_exercise.title
          refute_text ruby_exercise.title

          within(".automation-header") do
            click_on "C#"
            find("label", text: "Ruby").click
          end

          assert_text ruby_exercise.title
          refute_text csharp_exercise.title
        end
      end

      test "mentor gives feedback on representation without feedback" do
        mentor = create :user, :supermentor, mentor_satisfaction_percentage: 96.5
        track = create :track, slug: :csharp, title: 'C#'
        exercise = create :practice_exercise, :random_slug, track: track
        create :exercise_representation, exercise: exercise, feedback_type: nil, num_submissions: 3
        create :user_track_mentorship, :supermentor_frequency, user: mentor, track: track

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_automation_index_path

          click_on exercise.title

          open_editor
          fill_in_editor "Hello", within: ".comment-section"
          click_on "Preview & Submit"
          click_on "Submit"
          click_on "Continue to solutions requiring feedback", match: :first

          # We've been redirected to the need feedback page so verify that the
          # representation we just gave feedback on is no longer visible
          refute_text exercise.title

          click_on "Feedback submitted"
          assert_text exercise.title
        end
      end

      test "mentor sees only supermentor frequency tracks where feedback has been given on with feedback page" do
        mentor = create :user, :supermentor

        csharp = create :track, slug: :csharp, title: 'C#'
        ruby = create :track, slug: :ruby, title: 'Ruby'

        csharp_exercise = create :practice_exercise, track: csharp
        ruby_exercise = create :practice_exercise, track: ruby

        create :exercise_representation, :with_feedback, exercise: csharp_exercise, num_submissions: 3, feedback_author: mentor
        create :exercise_representation, exercise: ruby_exercise, feedback_type: nil, num_submissions: 3

        create :user_track_mentorship, :supermentor_frequency, user: mentor, track: csharp
        create :user_track_mentorship, :supermentor_frequency, user: mentor, track: ruby

        use_capybara_host do
          sign_in!(mentor)
          visit with_feedback_mentoring_automation_index_path

          within(".automation-header") do
            click_on "C#"

            assert_text csharp.title
            refute_text ruby.title
          end
        end
      end
    end
  end
end
