require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class MentorViewsPreviousSessionsTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "mentor views previous session" do
      TestHelpers.use_website_copy_test_repo!

      mentor = create :user, handle: "author"
      student = create :user, handle: "student-123"

      running = create :concept_exercise, slug: "running"
      solution = create :concept_solution, exercise: running, user: student
      running_discussion = create(:mentor_discussion, :finished, solution:, mentor:)
      submission = create(:submission, solution:)
      create(:iteration, submission:)

      lasagna = create :concept_exercise, slug: "lasagna"
      solution = create :concept_solution, exercise: lasagna, user: student
      discussion = create(:mentor_discussion, solution:, mentor:)
      submission = create(:submission, solution:)
      create(:iteration, submission:)

      create :mentor_student_relationship, mentor:, student:, num_discussions: 2

      use_capybara_host do
        sign_in!(mentor)
        visit mentoring_discussion_path(discussion)
        click_on "See 1 previous session"

        assert_text "You have 1 previous discussion"
        assert_text "student-123"
        assert_link "Running", href: Exercism::Routes.mentoring_discussion_url(running_discussion)
      end
    end

    test "mentor favorites a student" do
      TestHelpers.use_website_copy_test_repo!

      mentor = create :user, handle: "author"
      student = create :user, handle: "student-123"
      create :mentor_student_relationship, mentor:, student:, num_discussions: 2

      lasagna = create :concept_exercise, slug: "lasagna"
      solution = create :concept_solution, exercise: lasagna, user: student
      discussion = create(:mentor_discussion, solution:, mentor:)
      submission = create(:submission, solution:)
      create(:iteration, submission:)

      use_capybara_host do
        sign_in!(mentor)
        visit mentoring_discussion_path(discussion)
        click_on "See 1 previous session"
        within(".m-mentoring-sessions") { click_on "Add to favorites" }

        assert_text "Favorited"
      end
    end
  end
end
