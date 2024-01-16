require "application_system_test_case"
require_relative "../../../support/capybara_helpers"
require_relative "../../../support/markdown_editor_helpers"

module Flows
  module Mentor
    class SupermentorGivesFeedbackToRepresentationTest < ApplicationSystemTestCase
      include CapybaraHelpers
      include MarkdownEditorHelpers

      test "mentor sees all feedback of their supermentor frequency tracks where feedback has been given on admin page" do
        mentor = create :user, :supermentor
        other_mentor = create :user, :supermentor

        track = create :track, slug: :csharp, title: 'C#'

        exercise_1 = create :practice_exercise, track:, slug: 'bob'
        exercise_2 = create :practice_exercise, track:, slug: 'leap'
        exercise_3 = create :practice_exercise, track:, slug: 'isogram'

        create :exercise_representation, :with_feedback, exercise: exercise_1, num_submissions: 3, feedback_author: mentor
        create :exercise_representation, :with_feedback, exercise: exercise_2, num_submissions: 2, feedback_author: other_mentor
        create :exercise_representation, exercise: exercise_3, feedback_type: nil, num_submissions: 3

        create(:user_track_mentorship, :automator, user: mentor, track:)
        create(:user_track_mentorship, :automator, user: other_mentor, track:)

        use_capybara_host do
          sign_in!(mentor)
          visit admin_mentoring_automation_index_path

          assert_text exercise_1.title
          assert_text exercise_2.title
          refute_text exercise_3.title
        end
      end

      test "mentor changes orders on admin page" do
        mentor = create :user, :supermentor
        other_mentor = create :user, :supermentor

        track = create :track, slug: :csharp, title: 'C#'

        exercise_1 = create :practice_exercise, track:, slug: 'bob'
        exercise_2 = create :practice_exercise, track:, slug: 'leap'

        time_1 = Time.zone.now.beginning_of_day
        time_2 = time_1 - 1.day

        create :exercise_representation, :with_feedback, exercise: exercise_1, num_submissions: 3, feedback_author: mentor,
          feedback_added_at: time_1
        create :exercise_representation, :with_feedback, exercise: exercise_2, num_submissions: 2, feedback_author: other_mentor,
          feedback_added_at: time_2

        create(:user_track_mentorship, :automator, user: mentor, track:)
        create(:user_track_mentorship, :automator, user: other_mentor, track:)

        use_capybara_host do
          sign_in!(mentor)
          visit admin_mentoring_automation_index_path

          assert_text exercise_1.title
          assert_text exercise_2.title

          first_element_title = find('.--representer:first-child .--exercise-title div').text
          assert_equal exercise_1.title, first_element_title

          find('.automation-sorter button').click
          find("label", text: "Least recent feedback").click

          # wait for page to render
          assert_text exercise_2.title

          first_element_title = find('.--representer:first-child .--exercise-title div').text
          assert_equal exercise_2.title, first_element_title
        end
      end

      test "mentor filters for only mentored solutions on admin page" do
        mentor_1 = create :user, :supermentor
        mentor_2 = create :user, :supermentor
        track = create :track, slug: :csharp, title: 'C#'
        exercise_1 = create :practice_exercise, track:, slug: 'bob'
        exercise_2 = create :practice_exercise, track:, slug: 'leap'
        exercise_3 = create :practice_exercise, track:, slug: 'isogram'

        representation_1 = create(:exercise_representation, :with_feedback, feedback_type: :essential, num_submissions: 4,
          ast_digest: 'digest_1', exercise: exercise_1, track:)
        create :submission_representation, ast_digest: representation_1.ast_digest, mentored_by: mentor_2,
          submission: create(:submission, exercise: exercise_1)
        representation_2 = create(:exercise_representation, :with_feedback, feedback_type: :essential, num_submissions: 4,
          ast_digest: 'digest_2', exercise: exercise_2, track:)
        create :submission_representation, ast_digest: representation_2.ast_digest, mentored_by: mentor_1,
          submission: create(:submission, exercise: exercise_2)
        representation_3 = create(:exercise_representation, :with_feedback, feedback_type: :essential, num_submissions: 4,
          ast_digest: 'digest_3', exercise: exercise_3, track:)
        create :submission_representation, ast_digest: representation_3.ast_digest, mentored_by: mentor_1,
          submission: create(:submission, exercise: exercise_3)
        create(:user_track_mentorship, :automator, user: mentor_1, track:)

        use_capybara_host do
          sign_in!(mentor_1)
          visit admin_mentoring_automation_index_path

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

      test "mentor changes track on admin page" do
        mentor = create :user, :supermentor

        csharp = create :track, slug: :csharp, title: 'C#'
        ruby = create :track, slug: :ruby, title: 'Ruby'

        csharp_exercise = create :practice_exercise, :random_slug, track: csharp
        ruby_exercise = create :practice_exercise, :random_slug, track: ruby

        create :exercise_representation, :with_feedback, exercise: csharp_exercise, feedback_type: :essential, num_submissions: 3
        create :exercise_representation, :with_feedback, exercise: ruby_exercise, feedback_type: :essential, num_submissions: 2

        create :user_track_mentorship, :automator, user: mentor, track: csharp
        create :user_track_mentorship, :automator, user: mentor, track: ruby

        use_capybara_host do
          sign_in!(mentor)
          visit admin_mentoring_automation_index_path

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
    end
  end
end
