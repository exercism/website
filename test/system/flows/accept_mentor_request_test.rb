require "application_system_test_case"
require_relative "../../support/capybara_helpers"
require_relative "../../support/markdown_editor_helpers"
require_relative "../../support/redirect_helpers"

module Flows
  class AcceptMentorRequestTest < ApplicationSystemTestCase
    include CapybaraHelpers
    include MarkdownEditorHelpers
    include RedirectHelpers

    test "shows latest iteration marker" do
      solution = create :concept_solution
      request = create(:mentor_request, solution:)
      create :iteration, idx: 1, solution:, created_at: 1.week.ago

      use_capybara_host do
        sign_in!
        visit mentoring_request_path(request)

        assert_text "Iteration 1was submitted\n7d ago"
      end
    end

    test "shows request comment" do
      student = create :user, handle: "student"
      solution = create :concept_solution, user: student
      request = create :mentor_request, solution:, comment_markdown: "How to do this?",
        created_at: 2.days.ago
      create :iteration, idx: 1, solution:, created_at: Date.new(2016, 12, 25)

      use_capybara_host do
        sign_in!
        visit mentoring_request_path(request)

        assert_css "img[src='#{student.avatar_url}']"
        assert_text "How to do this?"
        assert_text "student"
        assert_text "2d ago"
      end
    end

    test "when request comment is blank, it is hidden" do
      student = create :user, handle: "student"
      solution = create :concept_solution, user: student
      request = create :mentor_request, :v2, solution:, comment_markdown: ""
      create(:iteration, idx: 1, solution:)

      use_capybara_host do
        sign_in!
        visit mentoring_request_path(request)
      end

      refute_css ".post"
    end

    test "mentor starts mentoring" do
      mentor = create :user, handle: "author"
      student = create :user, handle: "student"
      solution = create :concept_solution, user: student
      request = create :mentor_request, solution:, comment_markdown: "How to do this?",
        updated_at: 2.days.ago
      submission = create(:submission, solution:)
      create(:iteration, idx: 1, solution:, created_at: Date.new(2016, 12, 25), submission:)

      use_capybara_host do
        sign_in!(mentor)
        visit mentoring_request_path(request)

        click_on "Start mentoring"
        fill_in_editor "# Hello", within: ".comment-section"
        click_on "Send"

        wait_for_redirect
        assert_css "img[src='#{mentor.avatar_url}']"
        assert_text "author"
        assert_text "Hello"
      end
    end

    test "favorite button is hidden when there is no discussion yet" do
      solution = create :concept_solution
      request = create(:mentor_request, solution:)
      create :iteration, idx: 1, solution:, created_at: 1.week.ago

      use_capybara_host do
        sign_in!
        visit mentoring_request_path(request)

        assert_no_button "Add to favorites"
      end
    end

    test "mentor sees unavailable request" do
      expecting_errors do
        solution = create :concept_solution
        request = create :mentor_request, solution:, status: :cancelled

        use_capybara_host do
          sign_in!
          visit mentoring_request_path(request)

          assert_link "Back to list", href: mentoring_queue_path
        end
      end
    end
  end
end
