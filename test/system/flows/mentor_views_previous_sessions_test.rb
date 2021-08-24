require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class MentorViewsPreviousSessionsTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "mentor views previous session" do
      mentor = create :user
      student = create :user, handle: "student-123"

      lasagna = create :concept_exercise, slug: "lasagna"
      solution = create :concept_solution, exercise: lasagna, user: student
      lasagna_discussion = create :mentor_discussion, :finished, solution: solution, mentor: mentor
      submission = create :submission, solution: solution
      create :iteration, submission: submission

      running = create :concept_exercise, slug: "running"
      solution = create :concept_solution, exercise: running, user: student
      discussion = create :mentor_discussion, solution: solution, mentor: mentor
      submission = create :submission, solution: solution
      create :iteration, submission: submission

      use_capybara_host do
        sign_in!(mentor)
        visit mentoring_discussion_path(discussion)
        click_on "See 1 previous session"

        assert_text "You have 1 previous discussion"
        assert_text "student-123"
        assert_link "Lasagna", href: Exercism::Routes.mentoring_discussion_url(lasagna_discussion)

        assert_no_link "Running"
      end
    end

    test "mentor does not see button if there are no previous sessions" do
      mentor = create :user
      student = create :user

      running = create :concept_exercise
      solution = create :concept_solution, exercise: running, user: student
      discussion = create :mentor_discussion, solution: solution, mentor: mentor
      submission = create :submission, solution: solution
      create :iteration, submission: submission

      use_capybara_host do
        sign_in!(mentor)
        visit mentoring_discussion_path(discussion)
        assert_no_link "previous session"
      end
    end

    test "mentor views previous sessions in a mentor request" do
      mentor = create :user
      student = create :user

      lasagna = create :concept_exercise, slug: "lasagna"
      solution = create :concept_solution, exercise: lasagna, user: student
      create :mentor_discussion, :finished, solution: solution, mentor: mentor
      submission = create :submission, solution: solution
      create :iteration, submission: submission

      running = create :concept_exercise, slug: "running"
      solution = create :concept_solution, exercise: running, user: student
      create :mentor_discussion, solution: solution, mentor: mentor
      submission = create :submission, solution: solution
      create :iteration, submission: submission

      solution = create :concept_solution, user: student
      request = create :mentor_request, solution: solution
      create :iteration, idx: 1, solution: solution

      use_capybara_host do
        sign_in!(mentor)
        visit mentoring_request_path(request)
        click_on "See 2 previous sessions"

        assert_text "You have 2 previous discussions"
        assert_link "Lasagna"
        assert_link "Running"
      end
    end

    test "mentor moves through previous session pages" do
      Mentor::Discussion::Retrieve.stubs(:requests_per_page).returns(1)
      mentor = create :user
      student = create :user

      lasagna = create :concept_exercise, slug: "lasagna"
      solution = create :concept_solution, exercise: lasagna, user: student
      create :mentor_discussion, :finished, solution: solution, mentor: mentor
      submission = create :submission, solution: solution
      create :iteration, submission: submission

      walking = create :concept_exercise, slug: "walking"
      solution = create :concept_solution, exercise: walking, user: student
      walking_discussion = create :mentor_discussion, solution: solution, mentor: mentor
      submission = create :submission, solution: solution
      create :iteration, submission: submission

      running = create :concept_exercise, slug: "running"
      solution = create :concept_solution, exercise: running, user: student
      discussion = create :mentor_discussion, solution: solution, mentor: mentor
      submission = create :submission, solution: solution
      create :iteration, submission: submission

      use_capybara_host do
        sign_in!(mentor)
        visit mentoring_discussion_path(discussion)
        click_on "See 2 previous sessions"
        click_on "Next"

        assert_link "Walking", href: Exercism::Routes.mentoring_discussion_url(walking_discussion)
        assert_no_link "Lasagna"
      end
    end

    test "mentor favorites a student" do
      mentor = create :user
      student = create :user

      lasagna = create :concept_exercise, slug: "lasagna"
      solution = create :concept_solution, exercise: lasagna, user: student
      create :mentor_discussion, :finished, solution: solution, mentor: mentor
      submission = create :submission, solution: solution
      create :iteration, submission: submission

      running = create :concept_exercise, slug: "running"
      solution = create :concept_solution, exercise: running, user: student
      discussion = create :mentor_discussion, solution: solution, mentor: mentor
      submission = create :submission, solution: solution
      create :iteration, submission: submission

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
