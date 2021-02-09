require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Components
  module Mentoring
    class QueueTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "shows correct information" do
        ruby = create :track, title: "Ruby"
        series = create :concept_exercise, title: "Series", track: ruby
        mentee = create :user, handle: "mentee"
        mentor = create :user
        request = create :solution_mentor_request,
          exercise: series,
          user: mentee,
          created_at: 1.year.ago

        sign_in!(mentor)
        visit mentor_dashboard_path

        assert_css "img[src='https://assets.exercism.io/tracks/ruby-hex-white.png'][alt='icon for Ruby track']"
        assert_css "img[src='#{mentee.avatar_url}'][alt=\"Uploaded avatar of mentee\"]"
        assert_text "mentee"
        assert_text "on Series"
        assert_text "First timer"
        assert_text "a year ago"
        assert_link "", href: Exercism::Routes.mentor_request_url(request)
        assert_css "title", text: "Starred student", visible: false
        assert_css ".dot"
      end

      test "paginates results" do
        Solution::MentorRequest::Retrieve.stubs(requests_per_page: 1)
        mentor = create :user
        ruby = create :track, title: "Ruby"
        series = create :concept_exercise, title: "Series", track: ruby
        mentee = create :user, handle: "mentee"
        create :solution_mentor_request,
          exercise: series,
          user: mentee
        tournament = create :concept_exercise, title: "Tournament", track: ruby
        create :solution_mentor_request,
          exercise: tournament,
          user: mentee

        sign_in!(mentor)
        visit mentor_dashboard_path
        click_on "2"

        assert_text "on Tournament"
      end

      test "filter by query" do
        Solution::MentorRequest::Retrieve.stubs(requests_per_page: 1)
        mentor = create :user
        ruby = create :track, title: "Ruby"
        series = create :concept_exercise, title: "Series", track: ruby
        mentee = create :user, handle: "mentee"
        create :solution_mentor_request,
          exercise: series,
          user: mentee
        tournament = create :concept_exercise, title: "Tournament", track: ruby
        other_mentee = create :user, handle: "Other"
        create :solution_mentor_request,
          exercise: tournament,
          user: other_mentee

        sign_in!(mentor)
        visit mentor_dashboard_path
        fill_in "Filter by student handle", with: "Oth"

        assert_text "on Tournament"
      end

      test "sort by student" do
        Solution::MentorRequest::Retrieve.stubs(requests_per_page: 1)
        mentor = create :user
        ruby = create :track, title: "Ruby"
        series = create :concept_exercise, title: "Series", track: ruby
        mentee = create :user, name: "User 2"
        create :solution_mentor_request,
          exercise: series,
          user: mentee
        tournament = create :concept_exercise, title: "Tournament", track: ruby
        other_mentee = create :user, name: "User 1"
        create :solution_mentor_request,
          exercise: tournament,
          user: other_mentee

        sign_in!(mentor)
        visit mentor_dashboard_path
        select "Sort by Student", from: "mentoring-queue-sorter", exact: true

        assert_text "on Tournament"
      end

      test "filters by language track" do
        Solution::MentorRequest::Retrieve.stubs(requests_per_page: 1)
        mentor = create :user
        ruby = create :track, title: "Ruby", slug: "ruby"
        series = create :concept_exercise, title: "Series", track: ruby
        mentee = create :user, name: "User 2"
        create :solution_mentor_request,
          exercise: series,
          user: mentee
        csharp = create :track, title: "C#", slug: "csharp"
        tournament = create :concept_exercise, title: "Tournament", track: csharp
        other_mentee = create :user, name: "User 1"
        create :solution_mentor_request,
          exercise: tournament,
          user: other_mentee

        sign_in!(mentor)
        visit mentor_dashboard_path
        find("label", text: "C#").click

        assert_text "on Tournament"
      end

      test "filters by exercise" do
        Solution::MentorRequest::Retrieve.stubs(requests_per_page: 1)
        mentor = create :user
        mentee = create :user
        ruby = create :track, title: "Ruby", slug: "ruby"
        rust = create :track, title: "Rust", slug: "rust"
        series = create :concept_exercise, title: "Series", track: ruby, slug: "series"
        create :solution_mentor_request, exercise: series, user: mentee
        tournament = create :concept_exercise, title: "Tournament", track: rust, slug: "tournament"
        running = create :concept_exercise, title: "Running", track: rust, slug: "running"
        create :solution_mentor_request, exercise: tournament, user: mentee
        create :solution_mentor_request, exercise: running, user: mentee

        use_capybara_host do
          sign_in!(mentor)
          visit mentor_dashboard_path
          find("label", text: "Rust").click
          find("label", text: "Running").click

          assert_text "on Running"
        end
      end

      test "resets filters" do
        mentor = create :user
        mentee = create :user
        ruby = create :track, title: "Ruby", slug: "ruby"
        series = create :concept_exercise, title: "Series", track: ruby, slug: "series"
        create :solution_mentor_request, exercise: series, user: mentee
        tournament = create :concept_exercise, title: "Tournament", track: ruby, slug: "tournament"
        create :solution_mentor_request, exercise: tournament, user: mentee

        sign_in!(mentor)
        visit mentor_dashboard_path
        find("label", text: "Tournament").click
        click_on "Reset filter"

        assert_text "Showing 2 requests"
        assert_text "2 queued requests"
      end

      test "shows counts" do
        Solution::MentorRequest::Retrieve.stubs(requests_per_page: 1)
        mentor = create :user
        ruby = create :track, title: "Ruby"
        series = create :concept_exercise, title: "Series", track: ruby
        mentee = create :user, handle: "mentee"
        create :solution_mentor_request,
          exercise: series,
          user: mentee
        tournament = create :concept_exercise, title: "Tournament", track: ruby
        other_mentee = create :user, handle: "Other"
        create :solution_mentor_request,
          exercise: tournament,
          user: other_mentee

        sign_in!(mentor)
        visit mentor_dashboard_path
        fill_in "Filter by student handle", with: "Oth"

        assert_text "Showing 1 request"
        assert_text "2 queued requests"
      end

      test "shows and hides exercises that require mentoring" do
        mentor = create :user
        ruby = create :track, title: "Ruby"
        series = create :concept_exercise, title: "Series", track: ruby
        create :solution_mentor_request, exercise: series
        tournament = create :concept_exercise, title: "Tournament", track: ruby
        create :solution_mentor_request, exercise: tournament
        create :concept_exercise, title: "Running", track: ruby

        sign_in!(mentor)
        visit mentor_dashboard_path

        assert_no_text "Running"
        find("label", text: "Only show exercises that need mentoring").click
        assert_text "Running"
      end

      test "shows exercises that have been completed by mentor" do
        mentor = create :user
        ruby = create :track, title: "Ruby"
        series = create :concept_exercise, title: "Series", track: ruby, slug: "series"
        create :solution_mentor_request, exercise: series
        tournament = create :concept_exercise, title: "Tournament", track: ruby, slug: "tournament"
        create :solution_mentor_request, exercise: tournament
        create :concept_exercise, title: "Running", track: ruby
        create :concept_solution, completed_at: 2.days.ago, user: mentor, exercise: tournament

        sign_in!(mentor)
        visit mentor_dashboard_path
        find("label", text: "Series").click
        find("label", text: "Only show exercises I've completed").click

        assert_text "on Tournament"
        assert_no_text "on Series"
      end

      test "selects all exercises" do
        mentor = create :user
        ruby = create :track, title: "Ruby"
        series = create :concept_exercise, title: "Series", track: ruby, slug: "series"
        create :solution_mentor_request, exercise: series
        tournament = create :concept_exercise, title: "Tournament", track: ruby, slug: "tournament"
        create :solution_mentor_request, exercise: tournament

        sign_in!(mentor)
        visit mentor_dashboard_path
        find("label", text: "Series").click
        click_on "Select all"

        assert_text "on Series"
        assert_text "on Tournament"
      end

      test "deselects all exercises" do
        mentor = create :user
        ruby = create :track, title: "Ruby"
        series = create :concept_exercise, title: "Series", track: ruby, slug: "series"
        create :solution_mentor_request, exercise: series
        tournament = create :concept_exercise, title: "Tournament", track: ruby, slug: "tournament"
        create :solution_mentor_request, exercise: tournament

        sign_in!(mentor)
        visit mentor_dashboard_path
        find("label", text: "Series").click
        click_on "Select none"

        assert_text "on Series"
        assert_text "on Tournament"
      end
    end
  end
end
