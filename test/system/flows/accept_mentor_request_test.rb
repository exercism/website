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
  end
end
