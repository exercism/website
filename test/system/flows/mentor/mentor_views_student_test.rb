require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Mentor
    class MentorViewsStudentTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "mentor views student" do
        mentor = create :user
        student = create :user, handle: "margaret", name: "Marge"

        discussion = create(:mentor_discussion, mentor:, student:)
        submission = create :submission, solution: discussion.solution
        create(:iteration, submission:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)

          within(".student-info") do
            assert_text "Marge"
            assert_text "margaret"
          end
        end
      end

      test "mentor views previous discussions with student" do
        mentor = create :user
        student = create :user, handle: "margaret", name: "Marge"

        exercises = %i[anagram allergies leap satellite].map do |slug|
          create(:practice_exercise, slug:)
        end

        # Create previous discussions
        3.times do |idx|
          solution = create :practice_solution, exercise: exercises[idx], user: student
          request = create(:mentor_request, solution:)
          submission = create(:submission, solution:)
          iteration = create(:iteration, submission:)
          ::Mentor::Discussion::Create.(mentor, request, iteration.idx, "I need help")
        end

        solution = create :practice_solution, exercise: exercises[3], user: student
        request = create(:mentor_request, solution:)
        submission = create(:submission, solution:)
        iteration = create(:iteration, submission:)
        discussion = ::Mentor::Discussion::Create.(mentor, request, iteration.idx, "General tips")

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          click_on "See 3 previous sessions"
          within(".discussions") do
            assert_text "Anagram"
            assert_text "Allergies"
            assert_text "Leap"
            refute_text "Satellite"
          end
        end
      end
    end
  end
end
