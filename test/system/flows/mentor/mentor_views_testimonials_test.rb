require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Mentor
    class MentorViewsTestimonialsTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "mentor views testimonials" do
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

          assert_css "img[src='#{ruby.icon_url}']"
          assert_css "img[src='#{student.avatar_url}']"
          assert_text "student"
          assert_text "Great mentor!"
          assert_text "on Bob in Ruby"
          assert_text "yesterday"
        end
      end

      test "mentor searches testimonials" do
        mentor = create :user
        student = create :user, handle: "student"
        other_student = create :user, handle: "otherstudent"
        create :mentor_testimonial, :revealed, mentor:, student:, content: "Great mentor!"
        create :mentor_testimonial, :revealed, mentor:, student: other_student, content: "Too good!"

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_testimonials_path
          fill_in "Search by student name or testimonial", with: "oth"

          assert_text "Too good!"
          assert_no_text "Great mentor!"
        end
      end

      test "mentor switches pages" do
        ::Mentor::Testimonial::Retrieve.stubs(:testimonials_per_page).returns(1)
        mentor = create :user
        create(:mentor_testimonial, :revealed, content: "Great mentor!", mentor:)
        create(:mentor_testimonial, :revealed, content: "Too good!", mentor:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_testimonials_path
          click_on "Last"

          assert_text "Great mentor!"
          assert_no_text "Too good!"
        end
      end

      test "mentor orders testimonials" do
        ::Mentor::Testimonial::Retrieve.stubs(:testimonials_per_page).returns(1)
        mentor = create :user
        create(:mentor_testimonial, :revealed, created_at: 1.day.ago, content: "Great mentor!", mentor:)
        create(:mentor_testimonial, :revealed, created_at: 1.hour.ago, content: "Too good!", mentor:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_testimonials_path
          click_on "Sort by Unrevealed First"
          find("label", text: "Sort by Oldest First").click

          assert_text "Great mentor!"
          assert_no_text "Too good!"
        end
      end

      test "mentor filters testimonial by track" do
        mentor = create :user
        ruby = create :track, slug: "ruby"
        bob = create :concept_exercise, title: "Bob", track: ruby
        discussion = create :mentor_discussion, solution: create(:concept_solution, exercise: bob)

        csharp = create :track, title: "C#", slug: "csharp"
        strings = create :concept_exercise, title: "Strings", track: csharp
        other_discussion = create :mentor_discussion, solution: create(:concept_solution, exercise: strings)

        create(:mentor_testimonial, :revealed, mentor:, content: "Great mentor!", discussion:)
        create :mentor_testimonial, :revealed, mentor:, discussion: other_discussion, content: "Too good!"

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_testimonials_path
          click_on "All Tracks", visible: false
          find("label", text: "C#").click

          assert_text "Too good!"
          assert_no_text "Great mentor!"
        end
      end

      test "mentor views testimonial in a modal" do
        mentor = create :user
        create :mentor_testimonial, :revealed, mentor:, content: "Great mentor!"

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_testimonials_path
          click_on "Great mentor!"

          within(".m-testimonial") { assert_text "Great mentor!" }
        end
      end

      test "mentor reveals a testimonial" do
        mentor = create :user
        create :mentor_testimonial, :unrevealed, mentor:, content: "Great mentor!"

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_testimonials_path
          click_on "Click / tap to reveal"

          within(".m-testimonial") { assert_text "Great mentor!" }
          click_on "Close modal"

          assert_text "NEW"
        end
      end
    end
  end
end
