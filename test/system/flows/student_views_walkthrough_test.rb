require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class StudentViewsWalkthroughTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "student views walkthrough" do
      use_capybara_host do
        sign_in!
        visit temp_walkthrough_url

        assert_text "Welcome to the Exercism installation guide!"
      end
    end
  end
end
