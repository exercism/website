require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Mentor
    class MentorViewsTestimonialsTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "mentor deletes testimonials" do
        mentor = create :user
        student = create :user, handle: "student"
        ruby = create :track
        bob = create :concept_exercise, title: "Bob", track: ruby
        solution = create :concept_solution, exercise: bob
        discussion = create(:mentor_discussion, solution:)
        create :mentor_testimonial, :revealed,
          mentor:,
          student:,
          content: "Great mentor!",
          discussion:,
          created_at: 1.day.ago

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_testimonials_path
          find(".options-button").click
          click_on "Delete testimonial"
          within(".m-generic-confirmation") { click_on("Delete testimonial") }

          assert_no_text "Great mentor!"
        end
      end
    end
  end
end
