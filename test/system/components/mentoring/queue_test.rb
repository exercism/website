require "application_system_test_case"
require_relative "../../../support/table_matchers"

module Components
  module Mentoring
    class QueueTest < ApplicationSystemTestCase
      include TableMatchers

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
        Solution::MentorRequest::Retrieve.stubs(:requests_per_page).returns(1)
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
        Solution::MentorRequest::Retrieve.stubs(:requests_per_page).returns(1)
        mentor = create :user
        ruby = create :track, title: "Ruby"
        series = create :concept_exercise, title: "Series", track: ruby
        mentee = create :user, handle: "mentee"
        create :solution_mentor_request,
          exercise: series,
          user: mentee
        tournament = create :concept_exercise, title: "Tournament", track: ruby
        other_mentee = create :user, name: "Other"
        create :solution_mentor_request,
          exercise: tournament,
          user: other_mentee

        sign_in!(mentor)
        visit mentor_dashboard_path
        fill_in "Filter by student name", with: "Oth"

        assert_text "on Tournament"
      end

      test "sort by student" do
        Solution::MentorRequest::Retrieve.stubs(:requests_per_page).returns(1)
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
        Solution::MentorRequest::Retrieve.stubs(:requests_per_page).returns(1)
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
        Solution::MentorRequest::Retrieve.stubs(:requests_per_page).returns(1)
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

        assert_text "on Tournament"
      end

      test "resets filters" do
        skip

        visit test_components_mentoring_queue_url
        find("label", text: "C#").click
        click_on "Reset filter"

        assert_text "Showing 3 requests"
        assert_text "3 queued requests"
      end

      test "shows counts" do
        skip

        visit test_components_mentoring_queue_url
        find("label", text: "C#").click

        assert_text "Showing 1 request"
        assert_text "3 queued requests"
      end
    end
  end
end
