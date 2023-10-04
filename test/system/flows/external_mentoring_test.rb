require "application_system_test_case"
require_relative "../../support/capybara_helpers"
require_relative "../../support/markdown_editor_helpers"
require_relative "../../support/redirect_helpers"

module Flows
  class ExternalMentoringTest < ApplicationSystemTestCase
    include CapybaraHelpers
    include MarkdownEditorHelpers
    include RedirectHelpers

    test "logged out" do
      solution = create :concept_solution

      use_capybara_host do
        visit solution.external_mentoring_request_url

        assert_text "Want to mentor #{solution.user.handle}?"
        assert_link "Sign up for free"
      end
    end

    test "not a mentor with not enough rep" do
      solution = create :concept_solution
      user = create :user, :not_mentor, reputation: 19

      use_capybara_host do
        sign_in!(user)
        visit solution.external_mentoring_request_url

        assert_text "Want to mentor #{solution.user.handle}?"
        refute_button "Register as mentor"
        assert_text "Ability to mentor unlocks at"
      end
    end

    test "not a mentor with enough reps" do
      solution = create :concept_solution
      user = create :user, :not_mentor, reputation: 20

      use_capybara_host do
        sign_in!(user)
        visit solution.external_mentoring_request_url

        assert_text "Want to mentor #{solution.user.handle}?"
        assert_button "Register as mentor"
        assert_link "Learn more"
        click_on "Register as mentor"
        assert_text "Select the tracks you want to mentor"
      end
    end

    test "accept" do
      solution = create :concept_solution
      create :iteration, solution:, idx: 1

      use_capybara_host do
        sign_in!
        visit solution.external_mentoring_request_url

        assert_text "Want to mentor #{solution.user.handle}?"
        click_on "Accept invitation"

        sleep(1)
        assert_text "Iteration 1was submitted"
        assert_text "Who you're mentoring"
      end
    end
  end
end
