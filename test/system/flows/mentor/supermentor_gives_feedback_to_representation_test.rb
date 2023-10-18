require "application_system_test_case"
require_relative "../../../support/capybara_helpers"
require_relative "../../../support/markdown_editor_helpers"

module Flows
  module Mentor
    class SupermentorGivesFeedbackToRepresentationTest < ApplicationSystemTestCase
      include CapybaraHelpers
      include MarkdownEditorHelpers

      test "mentor sees only automator tracks on need feedback page" do
        mentor = create :user, :supermentor

        csharp = create :track, slug: :csharp, title: 'C#'
        ruby = create :track, slug: :ruby, title: 'Ruby'
        javascript = create :track, slug: :javascript, title: 'JavaScript'

        csharp_exercise = create :practice_exercise, track: csharp
        ruby_exercise = create :practice_exercise, track: ruby
        create :practice_exercise, track: javascript

        create :exercise_representation, exercise: csharp_exercise, feedback_type: nil, num_submissions: 3
        create :exercise_representation, exercise: ruby_exercise, feedback_type: nil, num_submissions: 2

        create :user_track_mentorship, :automator, user: mentor, track: csharp
        create :user_track_mentorship, user: mentor, track: javascript
        create :user_track_mentorship, :automator, user: mentor, track: ruby

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

        create :user_track_mentorship, :automator, user: mentor, track: csharp
        create :user_track_mentorship, :automator, user: mentor, track: ruby

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
        mentor = create :user, :supermentor
        mentor.update(cache: { 'mentor_satisfaction_percentage' => 96.5 })
        track = create :track, slug: :csharp, title: 'C#'
        exercise = create(:practice_exercise, :random_slug, track:)
        create :exercise_representation, exercise:, feedback_type: nil, num_submissions: 3
        create(:user_track_mentorship, :automator, user: mentor, track:)

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

      test "mentor filters for only mentored solutions" do
        mentor_1 = create :user, :supermentor
        mentor_2 = create :user, :supermentor
        track = create :track, slug: :csharp, title: 'C#'
        exercise_1 = create :practice_exercise, track:, slug: 'bob'
        exercise_2 = create :practice_exercise, track:, slug: 'leap'
        exercise_3 = create :practice_exercise, track:, slug: 'isogram'

        representation_1 = create(:exercise_representation, feedback_type: nil, num_submissions: 4,
          ast_digest: 'digest_1', exercise: exercise_1, track:)
        create :submission_representation, ast_digest: representation_1.ast_digest, mentored_by: mentor_2,
          submission: create(:submission, exercise: exercise_1)
        representation_2 = create(:exercise_representation, feedback_type: nil, num_submissions: 4,
          ast_digest: 'digest_2', exercise: exercise_2, track:)
        create :submission_representation, ast_digest: representation_2.ast_digest, mentored_by: mentor_1,
          submission: create(:submission, exercise: exercise_2)
        representation_3 = create(:exercise_representation, feedback_type: nil, num_submissions: 4,
          ast_digest: 'digest_3', exercise: exercise_3, track:)
        create :submission_representation, ast_digest: representation_3.ast_digest, mentored_by: mentor_1,
          submission: create(:submission, exercise: exercise_3)
        create(:user_track_mentorship, :automator, user: mentor_1, track:)

        use_capybara_host do
          sign_in!(mentor_1)
          visit mentoring_automation_index_path

          assert_text exercise_1.title
          assert_text exercise_2.title
          assert_text exercise_3.title

          find('label.c-checkbox-wrapper').click

          refute_text exercise_1.title
          assert_text exercise_2.title
          assert_text exercise_3.title

          find('label.c-checkbox-wrapper').click

          assert_text exercise_1.title
          assert_text exercise_2.title
          assert_text exercise_3.title
        end
      end

      test "mentor sees only automator tracks where feedback has been given on with feedback page" do
        mentor = create :user, :supermentor

        csharp = create :track, slug: :csharp, title: 'C#'
        ruby = create :track, slug: :ruby, title: 'Ruby'

        csharp_exercise = create :practice_exercise, track: csharp
        ruby_exercise = create :practice_exercise, track: ruby

        create :exercise_representation, :with_feedback, exercise: csharp_exercise, num_submissions: 3, feedback_author: mentor
        create :exercise_representation, exercise: ruby_exercise, feedback_type: nil, num_submissions: 3

        create :user_track_mentorship, :automator, user: mentor, track: csharp
        create :user_track_mentorship, :automator, user: mentor, track: ruby

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

      test "mentor changes orders" do
        mentor = create :user, :supermentor
        other_mentor = create :user, :supermentor

        track = create :track, slug: :csharp, title: 'C#'

        exercise_1 = create :practice_exercise, track:, slug: 'bob'
        exercise_2 = create :practice_exercise, track:, slug: 'leap'

        time_1 = Time.zone.now.beginning_of_day
        time_2 = time_1 - 1.day

        create :exercise_representation, feedback_type: nil, exercise: exercise_1, num_submissions: 3, created_at: time_2
        create :exercise_representation, feedback_type: nil, exercise: exercise_2, num_submissions: 2, created_at: time_1

        create(:user_track_mentorship, :automator, user: mentor, track:)
        create(:user_track_mentorship, :automator, user: other_mentor, track:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_automation_index_path

          assert_text exercise_1.title
          assert_text exercise_2.title

          first_element_title = find('.--representer:first-child .--exercise-title div').text
          assert_equal exercise_1.title, first_element_title

          find('.automation-sorter button').click
          find("label", text: "Sort by recent first").click

          # wait for page to render
          assert_text exercise_2.title

          first_element_title = find('.--representer:first-child .--exercise-title div').text
          assert_equal exercise_2.title, first_element_title

          find('.automation-sorter button').click
          find("label", text: "Sort by highest occurence").click

          # wait for page to render
          assert_text exercise_1.title

          first_element_title = find('.--representer:first-child .--exercise-title div').text
          assert_equal exercise_1.title, first_element_title
        end
      end

      test "mentor filters by exercise" do
        mentor = create :user, :supermentor
        other_mentor = create :user, :supermentor

        track = create :track, slug: :csharp, title: 'C#'

        exercise_1 = create :practice_exercise, track:, slug: 'bob'
        exercise_2 = create :practice_exercise, track:, slug: 'leap'

        time_1 = Time.zone.now.beginning_of_day
        time_2 = time_1 - 1.day

        create :exercise_representation, feedback_type: nil, exercise: exercise_1, num_submissions: 3, created_at: time_2
        create :exercise_representation, feedback_type: nil, exercise: exercise_2, num_submissions: 2, created_at: time_1

        create(:user_track_mentorship, :automator, user: mentor, track:)
        create(:user_track_mentorship, :automator, user: other_mentor, track:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_automation_index_path

          assert_text exercise_1.title
          assert_text exercise_2.title

          filter_input = find("input[placeholder='Filter by exercise (min 3 chars)']")

          filter_input.fill_in with: 'bo'
          sleep 1
          assert_text exercise_1.title
          assert_text exercise_2.title

          filter_input.send_keys('b')
          sleep 1
          assert_text exercise_1.title
          refute_text exercise_2.title

          filter_input.set('')
          sleep 1
          assert_text exercise_1.title
          assert_text exercise_2.title
        end
      end
    end
  end
end
