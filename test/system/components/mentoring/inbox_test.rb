require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Components
  module Mentoring
    class InboxTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "shows correct information" do
        mentor = create :user
        student = create :user, handle: "Mentee"
        ruby = create :track, title: "Ruby"
        series = create :concept_exercise, title: "Series", track: ruby
        solution = create :concept_solution, exercise: series, user: student
        discussion = create :mentor_discussion,
          :awaiting_mentor,
          solution:,
          mentor:,
          updated_at: 1.year.ago

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_inbox_url

          assert_css "img[src='#{ruby.icon_url}'][alt='icon for Ruby track']"
          assert_css "img[src='#{student.avatar_url}'][alt=\"Uploaded avatar of Mentee\"]"
          assert_text "Mentee"
          assert_text "on Series"
          assert_text "0"
          assert_text "1 year ago"
          assert_link "", href: Exercism::Routes.mentoring_discussion_url(discussion)
          refute_css "img[alt='Favorite student']"
        end
      end

      test "shows favourites" do
        mentor = create :user
        student = create :user, handle: "Mentee"
        solution = create :concept_solution, user: student
        create(:mentor_discussion, :awaiting_mentor, solution:, mentor:)
        create :mentor_student_relationship, mentor:, student:, favorited: true

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_inbox_url

          assert_css "img[alt='Favorite student']"
        end
      end

      test "paginates results" do
        ::Mentor::Discussion::Retrieve.stubs(:requests_per_page).returns(1)
        mentor = create :user
        series = create :concept_exercise, title: "Series"
        series_solution = create :concept_solution, exercise: series
        create(:mentor_discussion,
          :awaiting_mentor,
          solution: series_solution,
          mentor:)
        tournament = create :concept_exercise, title: "Tournament"
        tournament_solution = create :concept_solution, exercise: tournament
        create(:mentor_discussion,
          :awaiting_mentor,
          solution: tournament_solution,
          mentor:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_inbox_url

          assert_text "on Tournament"
          assert_no_text "on Series"

          click_on "2"

          assert_text "on Series"
          assert_no_text "on Tournament"
        end
      end

      test "filters by track" do
        ::Mentor::Discussion::Retrieve.stubs(:requests_per_page).returns(1)

        mentor = create :user
        ruby = create :track, title: "Ruby", slug: "ruby"
        go = create :track, title: "Go", slug: "go"

        series = create :concept_exercise, title: "Series", track: ruby
        series_solution = create :concept_solution, exercise: series
        create(:mentor_discussion, :awaiting_mentor, solution: series_solution, mentor:)

        tournament = create :concept_exercise, title: "Tournament", track: go
        tournament_solution = create :concept_solution, exercise: tournament
        create(:mentor_discussion, :awaiting_mentor, solution: tournament_solution, mentor:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_inbox_url
          click_on "All Tracks", visible: false
          find("label", text: "Go").click

          assert_text "on Tournament"
        end
      end

      test "filter by query" do
        ::Mentor::Discussion::Retrieve.stubs(:requests_per_page).returns(1)
        mentor = create :user
        ruby = create :track, title: "Ruby", slug: "ruby"
        go = create :track, title: "Go", slug: "go"
        series = create :concept_exercise, title: "Series", track: ruby
        series_solution = create :concept_solution, exercise: series
        create(:mentor_discussion,
          :awaiting_mentor,
          solution: series_solution,
          mentor:)
        tournament = create :concept_exercise, title: "Tournament", track: go
        tournament_solution = create :concept_solution, exercise: tournament
        create(:mentor_discussion,
          :awaiting_mentor,
          solution: tournament_solution,
          mentor:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_inbox_url
          fill_in "Filter by student or exercise name", with: "Tourn"

          assert_text "on Tournament"
        end
      end

      test "sort by student" do
        ::Mentor::Discussion::Retrieve.stubs(:requests_per_page).returns(1)
        mentor = create :user
        ruby = create :track, title: "Ruby", slug: "ruby"
        go = create :track, title: "Go", slug: "go"
        series = create :concept_exercise, title: "Series", track: ruby
        series_solution = create :concept_solution, exercise: series
        create(:mentor_discussion,
          :awaiting_mentor,
          solution: series_solution,
          mentor:)
        tournament = create :concept_exercise, title: "Tournament", track: go
        tournament_solution = create :concept_solution, exercise: tournament
        create(:mentor_discussion,
          :awaiting_mentor,
          solution: tournament_solution,
          mentor:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_inbox_url
          click_on "Sort by recent first"
          find("label", text: "Sort by exercise").click

          assert_text "on Series"
        end
      end

      test "filter by discussion status" do
        ::Mentor::Discussion::Retrieve.stubs(:requests_per_page).returns(1)
        mentor = create :user
        ruby = create :track, title: "Ruby", slug: "ruby"
        go = create :track, title: "Go", slug: "go"
        series = create :concept_exercise, title: "Series", track: ruby
        series_solution = create :concept_solution, exercise: series
        create(:mentor_discussion,
          :awaiting_mentor,
          solution: series_solution,
          mentor:)
        tournament = create :concept_exercise, title: "Tournament", track: go
        tournament_solution = create :concept_solution, exercise: tournament
        create(:mentor_discussion,
          :awaiting_student,
          solution: tournament_solution,
          mentor:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_inbox_url
          click_on "Awaiting student1"

          assert_text "on Tournament"
          assert_no_text "on Series"
          assert_button "Awaiting student1", disabled: true
        end
      end

      test "shows zero state" do
        mentor = create :user
        create :track, title: "Ruby", slug: "ruby"

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_inbox_url

          assert_text "No mentoring discussions"
          assert_link "Mentor a new solution", href: mentoring_queue_path
        end
      end
    end
  end
end
