require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Components
  module Mentoring
    class QueueTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "shows correct information for first timer" do
        mentor = create :user
        ruby = create :track, title: "Ruby"
        create :user_track_mentorship, track: ruby, user: mentor
        series = create :concept_exercise, title: "Series", track: ruby
        student = create :user, handle: "student"
        request = create_mentor_request exercise: series, student:, created_at: 1.year.ago

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_queue_path

          assert_css "img[src='#{ruby.icon_url}'][alt='icon for Ruby track']"
          assert_css "img[src='#{student.avatar_url}'][alt=\"Uploaded avatar of student\"]"
          assert_text "student"
          assert_text "on Series"
          assert_text "a year ago"
          assert_link "", href: Exercism::Routes.mentoring_request_url(request)
          assert_text "First timer"
          refute_css "img[alt='Favorite student']"
          refute_css ".previously-mentored"
        end
      end

      test "shows correct information for previous student" do
        mentor = create :user
        ruby = create :track, title: "Ruby"
        create :user_track_mentorship, track: ruby, user: mentor
        series = create :concept_exercise, title: "Series", track: ruby
        student = create :user, handle: "student"
        request = create_mentor_request exercise: series, student:, created_at: 1.year.ago
        relationship = create(:mentor_student_relationship, student:, mentor:)
        create :mentor_discussion, solution: create(:practice_solution, user: student),
          request: create(:mentor_request, status: :fulfilled)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_queue_path

          assert_css "img[src='#{ruby.icon_url}'][alt='icon for Ruby track']"
          assert_css "img[src='#{student.avatar_url}'][alt=\"Uploaded avatar of student\"]"
          assert_text "student"
          assert_text "on Series"
          assert_text "a year ago"
          assert_link "", href: Exercism::Routes.mentoring_request_url(request)
          refute_text "First timer"
          refute_css "img[alt='Favorite student']"
          assert_css ".previously-mentored"

          relationship.update!(favorited: true)
          visit mentoring_queue_path
          refute_text "First timer"
          assert_css "img[alt='Favorite student']"
          refute_css ".previously-mentored"
        end
      end

      test "paginates results" do
        ::Mentor::Request::Retrieve.stubs(requests_per_page: 1)
        mentor = create :user
        ruby = create :track, title: "Ruby"
        create :user_track_mentorship, track: ruby, user: mentor
        series = create :concept_exercise, title: "Series", track: ruby, slug: "series"
        student = create :user, handle: "student"
        create_mentor_request exercise: series, student:, created_at: Time.current - 1.week
        tournament = create :concept_exercise, title: "Tournament", track: ruby, slug: "tournament"
        create_mentor_request exercise: tournament, student:, created_at: Time.current - 1.day

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_queue_path
          assert_text "on Series"
          refute_text "on Tournament"

          click_on "2"

          assert_text "on Tournament"
          refute_text "on Series"
        end
      end

      test "filter by query" do
        ::Mentor::Request::Retrieve.stubs(requests_per_page: 1)
        mentor = create :user
        ruby = create :track, title: "Ruby"
        create :user_track_mentorship, track: ruby, user: mentor
        series = create :concept_exercise, title: "Series", track: ruby, slug: "series"
        student = create :user, handle: "student"
        create_mentor_request(exercise: series, student:)
        tournament = create :concept_exercise, title: "Tournament", track: ruby, slug: "tournament"
        other_student = create :user, handle: "Other"
        create_mentor_request exercise: tournament, student: other_student

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_queue_path
          fill_in "Filter by student handle", with: "Oth"

          assert_text "on Tournament"
        end
      end

      test "sort by recent" do
        ::Mentor::Request::Retrieve.stubs(requests_per_page: 1)

        mentor = create :user
        ruby = create :track, title: "Ruby"
        create :user_track_mentorship, track: ruby, user: mentor

        tournament = create :concept_exercise, title: "Tournament", track: ruby, slug: "tournament"
        create_mentor_request exercise: tournament, created_at: Time.current - 1.week

        series = create :concept_exercise, title: "Series", track: ruby, slug: "series"
        create_mentor_request exercise: series, created_at: Time.current

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_queue_path

          # Check default
          assert_text "on Tournament"
          refute_text "on Series"

          click_on "Sort by oldest first"
          find("label", text: "Sort by recent first").click
          refute_text "on Tournament"
          assert_text "on Series"

          click_on "Sort by recent first"
          find("label", text: "Sort by oldest first").click
          assert_text "on Tournament"
          refute_text "on Series"
        end
      end

      test "filters by language track" do
        ::Mentor::Request::Retrieve.stubs(requests_per_page: 1)
        mentor = create :user
        ruby = create :track, title: "Ruby", slug: "ruby"
        create :user_track_mentorship, track: ruby, user: mentor
        series = create :concept_exercise, title: "Series", track: ruby, slug: "series"
        student = create :user, name: "User 2"
        create_mentor_request(exercise: series, student:)
        csharp = create :track, title: "C#", slug: "csharp"
        create :user_track_mentorship, track: csharp, user: mentor
        tournament = create :concept_exercise, title: "Tournament", track: csharp, slug: "tournament"
        other_student = create :user, name: "User 1"
        create_mentor_request exercise: tournament, student: other_student

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_queue_path
          within(".mentor-queue-filtering") { click_on "C#" }
          find("label", text: "Ruby").click

          assert_text "on Series"
        end
      end

      test "language track filter shows correct counts" do
        ::Mentor::Request::Retrieve.stubs(requests_per_page: 1)
        mentor = create :user
        ruby = create :track, title: "Ruby", slug: "ruby"
        create :user_track_mentorship, track: ruby, user: mentor
        series = create :concept_exercise, title: "Series", track: ruby, slug: "series"
        student = create :user, name: "User 2"
        create_mentor_request(exercise: series, student:)
        csharp = create :track, title: "C#", slug: "csharp"
        create :user_track_mentorship, track: csharp, user: mentor
        tournament = create :concept_exercise, title: "Tournament", track: csharp, slug: "tournament"
        other_student = create :user, name: "User 1"
        create_mentor_request exercise: tournament, student: other_student

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_queue_path
          within(".mentor-queue-filtering") { assert_text "C# 1" }
        end
      end

      test "filters by exercise" do
        ::Mentor::Request::Retrieve.stubs(requests_per_page: 1)
        mentor = create :user
        student = create :user
        ruby = create :track, title: "Ruby", slug: "ruby"
        create :user_track_mentorship, track: ruby, user: mentor
        rust = create :track, title: "Rust", slug: "rust"
        create :user_track_mentorship, track: rust, user: mentor
        series = create :concept_exercise, title: "Series", track: ruby, slug: "series"
        create_mentor_request(exercise: series, student:)
        tournament = create :concept_exercise, title: "Tournament", track: rust, slug: "tournament"
        running = create :concept_exercise, title: "Running", track: rust, slug: "running"
        create_mentor_request(exercise: tournament, student:)
        create_mentor_request(exercise: running, student:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_queue_path
          within(".mentor-queue-filtering") { click_on "Ruby" }
          find("label", text: "Rust").click
          find("label", text: "Running").click

          assert_text "on Running"
        end
      end

      test "shows and hides exercises that require mentoring" do
        mentor = create :user
        ruby = create :track, title: "Ruby"
        create :user_track_mentorship, track: ruby, user: mentor
        series = create :concept_exercise, title: "Series", track: ruby, slug: "series"
        create_mentor_request exercise: series
        create :concept_exercise, title: "Tournament", track: ruby, slug: "tournament"

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_queue_path

          assert_no_text "Tournament"
          find("label", text: "Only show exercises that need mentoring").click
          assert_text "Tournament"
        end
      end

      test "shows exercises that have been completed by mentor" do
        mentor = create :user
        ruby = create :track, title: "Ruby"
        create :user_track_mentorship, track: ruby, user: mentor
        series = create :concept_exercise, title: "Series", track: ruby, slug: "series"
        create_mentor_request exercise: series
        tournament = create :concept_exercise, title: "Tournament", track: ruby, slug: "tournament"
        create_mentor_request exercise: tournament
        create :concept_exercise, title: "Running", track: ruby
        create :concept_solution, completed_at: 2.days.ago, user: mentor, exercise: tournament

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_queue_path
          find("label", text: "Series").click
          find("label", text: "Only show exercises I've completed").click
          within(".mentor-queue-filtering") do
            assert_text "Tournament"
            assert_no_text "Series"
          end
        end
      end

      def create_mentor_request(exercise: nil, student: nil, created_at: nil)
        solution_params = {}
        solution_params[:exercise] = exercise if exercise
        solution_params[:user] = student if student

        req_params = {}
        req_params[:created_at] = created_at if created_at
        req_params[:solution] = create(:concept_solution, solution_params)

        create :mentor_request, req_params
      end
    end
  end
end
