require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class AcceptMentorRequestTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "shows latest iteration marker" do
      solution = create :concept_solution
      request = create :solution_mentor_request, solution: solution
      create :iteration, idx: 1, solution: solution, created_at: Date.new(2016, 12, 25)

      use_capybara_host do
        sign_in!
        visit mentor_request_path(request)

        assert_text "Iteration 1\nwas submitted\n25 Dec 2016"
      end
    end

    test "shows request comment" do
      student = create :user, handle: "student"
      solution = create :concept_solution, user: student
      request = create :solution_mentor_request, solution: solution, comment: "How to do this?", updated_at: 2.days.ago
      create :iteration, idx: 1, solution: solution, created_at: Date.new(2016, 12, 25)

      use_capybara_host do
        sign_in!
        visit mentor_request_path(request)

        assert_css "img[src='#{student.avatar_url}']"
        assert_text "How to do this?"
        assert_text "student"
        assert_text "2 days ago"
      end
    end
  end
end
