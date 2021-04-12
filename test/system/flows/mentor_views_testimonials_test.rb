require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class MentorViewsTestimonialsTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "mentor views testimonials" do
      mentor = create :user
      student = create :user, handle: "student"
      ruby = create :track
      bob = create :concept_exercise, title: "Bob", track: ruby
      solution = create :concept_solution, exercise: bob
      discussion = create :mentor_discussion, solution: solution
      create :mentor_testimonial,
        mentor: mentor,
        student: student,
        content: "Great mentor!",
        discussion: discussion,
        created_at: 1.day.ago,
        revealed: true

      use_capybara_host do
        sign_in!(mentor)
        visit mentoring_testimonials_path

        assert_css "img[src='#{ruby.icon_url}']"
        assert_css "img[src='#{student.avatar_url}']"
        assert_text "student"
        assert_text "Great mentor!"
        assert_text "on Bob in Ruby"
        assert_text "a day ago"
      end
    end
  end
end
