require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Components
  module Mentoring
    class TestimonialsTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "shows zero state" do
        mentor = create :user

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_testimonials_url

          assert_text "You currently have no testimonials"
        end
      end
    end
  end
end
