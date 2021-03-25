require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Components
  module Mentoring
    class QueueTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "shows correct information" do
        mentor = create :user
        ruby = create :track, title: "Ruby"
        create :user_track_mentorship, track: ruby, user: mentor
        series = create :concept_exercise, title: "Series", track: ruby
        mentee = create :user, handle: "mentee"
        request = create :mentor_request,
          exercise: series,
          user: mentee,
          created_at: 1.year.ago

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_queue_path

          assert_css "img[src='#{ruby.icon_url}'][alt='icon for Ruby track']"
          assert_css "img[src='#{mentee.avatar_url}'][alt=\"Uploaded avatar of mentee\"]"
          assert_text "mentee"
          assert_text "on Series"
          assert_text "First timer"
          assert_text "a year ago"
          assert_link "", href: Exercism::Routes.mentoring_request_url(request)
          assert_css "img[alt='Starred student']", visible: false
          assert_css ".dot"
        end
      end

      test "paginates results" do
        Mentor::Request::Retrieve.stubs(requests_per_page: 1)
        mentor = create :user
        ruby = create :track, title: "Ruby"
        create :user_track_mentorship, track: ruby, user: mentor
        series = create :concept_exercise, title: "Series", track: ruby
        mentee = create :user, handle: "mentee"
        create :mentor_request,
          exercise: series,
          user: mentee
        tournament = create :concept_exercise, title: "Tournament", track: ruby
        create :mentor_request,
          exercise: tournament,
          user: mentee

        sign_in!(mentor)
        visit mentoring_queue_path
        click_on "2"

        assert_text "on Tournament"
      end

      test "filter by query" do
        Mentor::Request::Retrieve.stubs(requests_per_page: 1)
        mentor = create :user
        ruby = create :track, title: "Ruby"
        create :user_track_mentorship, track: ruby, user: mentor
        series = create :concept_exercise, title: "Series", track: ruby
        mentee = create :user, handle: "mentee"
        create :mentor_request,
          exercise: series,
          user: mentee
        tournament = create :concept_exercise, title: "Tournament", track: ruby
        other_mentee = create :user, handle: "Other"
        create :mentor_request,
          exercise: tournament,
          user: other_mentee

        sign_in!(mentor)
        visit mentoring_queue_path
        fill_in "Filter by student handle", with: "Oth"

        assert_text "on Tournament"
      end

      test "sort by student" do
        Mentor::Request::Retrieve.stubs(requests_per_page: 1)
        mentor = create :user
        ruby = create :track, title: "Ruby"
        create :user_track_mentorship, track: ruby, user: mentor
        series = create :concept_exercise, title: "Series", track: ruby
        mentee = create :user, name: "User 2"
        create :mentor_request,
          exercise: series,
          user: mentee
        tournament = create :concept_exercise, title: "Tournament", track: ruby
        other_mentee = create :user, name: "User 1"
        create :mentor_request,
          exercise: tournament,
          user: other_mentee

        sign_in!(mentor)
        visit mentoring_queue_path
        select "Sort by Student", from: "mentoring-queue-sorter", exact: true

        assert_text "on Tournament"
      end

      test "filters by language track" do
        Mentor::Request::Retrieve.stubs(requests_per_page: 1)
        mentor = create :user
        ruby = create :track, title: "Ruby", slug: "ruby"
        create :user_track_mentorship, track: ruby, user: mentor
        series = create :concept_exercise, title: "Series", track: ruby
        mentee = create :user, name: "User 2"
        create :mentor_request,
          exercise: series,
          user: mentee
        csharp = create :track, title: "C#", slug: "csharp"
        create :user_track_mentorship, track: csharp, user: mentor
        tournament = create :concept_exercise, title: "Tournament", track: csharp
        other_mentee = create :user, name: "User 1"
        create :mentor_request,
          exercise: tournament,
          user: other_mentee

        sign_in!(mentor)
        visit mentoring_queue_path
        find("label", text: "C#").click

        assert_text "on Tournament"
      end

      test "filters by exercise" do
        Mentor::Request::Retrieve.stubs(requests_per_page: 1)
        mentor = create :user
        mentee = create :user
        ruby = create :track, title: "Ruby", slug: "ruby"
        create :user_track_mentorship, track: ruby, user: mentor
        rust = create :track, title: "Rust", slug: "rust"
        create :user_track_mentorship, track: rust, user: mentor
        series = create :concept_exercise, title: "Series", track: ruby, slug: "series"
        create :mentor_request, exercise: series, user: mentee
        tournament = create :concept_exercise, title: "Tournament", track: rust, slug: "tournament"
        running = create :concept_exercise, title: "Running", track: rust, slug: "running"
        create :mentor_request, exercise: tournament, user: mentee
        create :mentor_request, exercise: running, user: mentee

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_queue_path
          find("label", text: "Rust").click
          find("label", text: "Running").click

          assert_text "on Running"
        end
      end

      test "resets filters" do
        mentor = create :user
        mentee = create :user
        ruby = create :track, title: "Ruby", slug: "ruby"
        create :user_track_mentorship, track: ruby, user: mentor
        series = create :concept_exercise, title: "Series", track: ruby, slug: "series"
        create :mentor_request, exercise: series, user: mentee
        tournament = create :concept_exercise, title: "Tournament", track: ruby, slug: "tournament"
        create :mentor_request, exercise: tournament, user: mentee

        sign_in!(mentor)
        visit mentoring_queue_path
        find("label", text: "Tournament").click
        click_on "Reset filter"

        assert_text "Showing 2 requests"
        assert_text "2 queued requests"
      end

      test "shows counts" do
        Mentor::Request::Retrieve.stubs(requests_per_page: 1)
        mentor = create :user
        ruby = create :track, title: "Ruby"
        create :user_track_mentorship, track: ruby, user: mentor
        series = create :concept_exercise, title: "Series", track: ruby
        mentee = create :user, handle: "mentee"
        create :mentor_request,
          exercise: series,
          user: mentee
        tournament = create :concept_exercise, title: "Tournament", track: ruby
        other_mentee = create :user, handle: "Other"
        create :mentor_request,
          exercise: tournament,
          user: other_mentee

        sign_in!(mentor)
        visit mentoring_queue_path
        fill_in "Filter by student handle", with: "Oth"

        assert_text "Showing 1 request"
        assert_text "2 queued requests"
      end

      test "shows and hides exercises that require mentoring" do
        mentor = create :user
        ruby = create :track, title: "Ruby"
        create :user_track_mentorship, track: ruby, user: mentor
        series = create :concept_exercise, title: "Series", track: ruby
        create :mentor_request, exercise: series
        tournament = create :concept_exercise, title: "Tournament", track: ruby
        create :mentor_request, exercise: tournament
        create :concept_exercise, title: "Running", track: ruby

        sign_in!(mentor)
        visit mentoring_queue_path

        assert_no_text "Running"
        find("label", text: "Only show exercises that need mentoring").click
        assert_text "Running"
      end

      test "shows exercises that have been completed by mentor" do
        mentor = create :user
        ruby = create :track, title: "Ruby"
        create :user_track_mentorship, track: ruby, user: mentor
        series = create :concept_exercise, title: "Series", track: ruby, slug: "series"
        create :mentor_request, exercise: series
        tournament = create :concept_exercise, title: "Tournament", track: ruby, slug: "tournament"
        create :mentor_request, exercise: tournament
        create :concept_exercise, title: "Running", track: ruby
        create :concept_solution, completed_at: 2.days.ago, user: mentor, exercise: tournament

        sign_in!(mentor)
        visit mentoring_queue_path
        find("label", text: "Series").click
        find("label", text: "Only show exercises I've completed").click

        assert_text "on Tournament"
        assert_no_text "on Series"
      end

      test "selects all exercises" do
        mentor = create :user
        ruby = create :track, title: "Ruby"
        create :user_track_mentorship, track: ruby, user: mentor
        series = create :concept_exercise, title: "Series", track: ruby, slug: "series"
        create :mentor_request, exercise: series
        tournament = create :concept_exercise, title: "Tournament", track: ruby, slug: "tournament"
        create :mentor_request, exercise: tournament

        sign_in!(mentor)
        visit mentoring_queue_path
        find("label", text: "Series").click
        click_on "Select all"

        assert_text "on Series"
        assert_text "on Tournament"
      end

      test "deselects all exercises" do
        mentor = create :user
        ruby = create :track, title: "Ruby"
        create :user_track_mentorship, track: ruby, user: mentor
        series = create :concept_exercise, title: "Series", track: ruby, slug: "series"
        create :mentor_request, exercise: series
        tournament = create :concept_exercise, title: "Tournament", track: ruby, slug: "tournament"
        create :mentor_request, exercise: tournament

        sign_in!(mentor)
        visit mentoring_queue_path
        find("label", text: "Series").click
        click_on "Select none"

        assert_text "on Series"
        assert_text "on Tournament"
      end
    end
  end
end
