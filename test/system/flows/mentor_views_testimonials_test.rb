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
      create :user_track_mentorship, track: ruby, user: mentor

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

    test "mentor searches testimonials" do
      mentor = create :user
      student = create :user, handle: "student"
      other_student = create :user, handle: "otherstudent"
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
      create :mentor_testimonial, mentor: mentor, student: other_student, content: "Too good!", revealed: true
      create :user_track_mentorship, track: ruby, user: mentor

      use_capybara_host do
        sign_in!(mentor)
        visit mentoring_testimonials_path
        fill_in "Search by student name or testimonial", with: "oth"

        assert_text "Too good!"
        assert_no_text "Great mentor!"
      end
    end

    test "mentor switches pages" do
      Mentor::Testimonial::Retrieve.stubs(:testimonials_per_page).returns(1)
      mentor = create :user
      student = create :user, handle: "student"
      other_student = create :user, handle: "otherstudent"
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
      create :mentor_testimonial, mentor: mentor, student: other_student, content: "Too good!", revealed: true
      create :user_track_mentorship, track: ruby, user: mentor

      use_capybara_host do
        sign_in!(mentor)
        visit mentoring_testimonials_path
        click_on "Last"

        assert_text "Great mentor!"
        assert_no_text "Too good!"
      end
    end

    test "mentor orders testimonials" do
      Mentor::Testimonial::Retrieve.stubs(:testimonials_per_page).returns(1)
      mentor = create :user
      student = create :user, handle: "student"
      other_student = create :user, handle: "otherstudent"
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
      create :mentor_testimonial,
        mentor: mentor,
        student: other_student,
        content: "Too good!",
        revealed: true,
        created_at: 2.days.ago
      create :user_track_mentorship, track: ruby, user: mentor

      use_capybara_host do
        sign_in!(mentor)
        visit mentoring_testimonials_path
        select "Sort by Oldest First"
        click_on "Last"

        assert_text "Too good!"
        assert_no_text "Great mentor!"
      end
    end

    test "mentor filters testimonial by track" do
      mentor = create :user
      student = create :user, handle: "student"
      other_student = create :user, handle: "otherstudent"
      ruby = create :track, slug: "ruby"
      bob = create :concept_exercise, title: "Bob", track: ruby
      solution = create :concept_solution, exercise: bob
      discussion = create :mentor_discussion, solution: solution
      csharp = create :track, title: "C#", slug: "csharp"
      strings = create :concept_exercise, title: "Strings", track: csharp
      solution = create :concept_solution, exercise: strings
      other_discussion = create :mentor_discussion, solution: solution
      create :mentor_testimonial,
        mentor: mentor,
        student: student,
        content: "Great mentor!",
        discussion: discussion,
        created_at: 1.day.ago,
        revealed: true
      create :mentor_testimonial,
        mentor: mentor,
        discussion: other_discussion,
        student: other_student,
        content: "Too good!",
        revealed: true,
        created_at: 2.days.ago
      create :user_track_mentorship, track: ruby, user: mentor
      create :user_track_mentorship, track: csharp, user: mentor

      use_capybara_host do
        sign_in!(mentor)
        visit mentoring_testimonials_path
        click_on "Open the track filter"
        find("label", text: "C#").click

        assert_text "Too good!"
        assert_no_text "Great mentor!"
      end
    end

    test "mentor views testimonial in a modal" do
      mentor = create :user
      student = create :user, handle: "student"
      ruby = create :track, slug: "ruby"
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
      create :user_track_mentorship, track: ruby, user: mentor

      use_capybara_host do
        sign_in!(mentor)
        visit mentoring_testimonials_path
        click_on "Great mentor!"

        within(".m-testimonial-modal") { assert_text "Great mentor!" }
      end
    end

    test "mentor reveals a testimonial" do
      mentor = create :user
      student = create :user, handle: "student"
      ruby = create :track, slug: "ruby"
      bob = create :concept_exercise, title: "Bob", track: ruby
      solution = create :concept_solution, exercise: bob
      discussion = create :mentor_discussion, solution: solution
      create :mentor_testimonial,
        mentor: mentor,
        student: student,
        content: "Great mentor!",
        discussion: discussion,
        created_at: 1.day.ago,
        revealed: false
      create :user_track_mentorship, track: ruby, user: mentor

      use_capybara_host do
        sign_in!(mentor)
        visit mentoring_testimonials_path
        click_on "Click / tap to reveal"

        within(".m-testimonial-modal") { assert_text "Great mentor!" }
        page.find("body").click

        assert_text "Revealed"
      end
    end
  end
end
