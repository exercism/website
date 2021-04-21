require "application_system_test_case"
require_relative "../../support/capybara_helpers"
require_relative "../../support/markdown_editor_helpers"

module Flows
  class AcceptMentorRequestTest < ApplicationSystemTestCase
    include CapybaraHelpers
    include MarkdownEditorHelpers

    test "shows latest iteration marker" do
      solution = create :concept_solution
      request = create :mentor_request, solution: solution
      create :iteration, idx: 1, solution: solution, created_at: 1.week.ago

      use_capybara_host do
        sign_in!
        visit mentoring_request_path(request)

        assert_text "Iteration 1was submitted\n7d ago"
      end
    end

    test "shows request comment" do
      student = create :user, handle: "student"
      solution = create :concept_solution, user: student
      request = create :mentor_request, solution: solution, comment_markdown: "How to do this?",
                                        updated_at: 2.days.ago
      create :iteration, idx: 1, solution: solution, created_at: Date.new(2016, 12, 25)

      use_capybara_host do
        sign_in!
        visit mentoring_request_path(request)

        assert_css "img[src='#{student.avatar_url}']"
        assert_text "How to do this?"
        assert_text "student"
        assert_text "2d ago"
      end
    end

    test "mentor starts mentoring" do
      mentor = create :user, handle: "author"
      student = create :user, handle: "student"
      solution = create :concept_solution, user: student
      request = create :mentor_request, solution: solution, comment_markdown: "How to do this?",
                                        updated_at: 2.days.ago
      create :iteration, idx: 1, solution: solution, created_at: Date.new(2016, 12, 25)

      use_capybara_host do
        sign_in!(mentor)
        visit mentoring_request_path(request)

        click_on "Start mentoring"
        fill_in_editor "# Hello", within: ".comment-section"
        click_on "Send"

        assert_css "img[src='#{mentor.avatar_url}']"
        assert_text "author"
        assert_text "Hello"
      end
    end
  end
end
