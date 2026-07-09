require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Journey
    class OverviewTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user sees track learning details" do
        Time.zone = "UTC"
        # The joined date and the "N years ago" text are both rendered client-side
        # by dayjs against the real browser clock, so travel_to (which only affects
        # the test process) can't pin them. Anchor the join date relative to now so
        # it stays exactly 9 years ago, permanently. Midday avoids any timezone
        # boundary flipping the displayed date.
        started_at = 9.years.ago.change(hour: 12)

        user = create :user
        track = create :track
        create :user_track, user:, track:, created_at: started_at

        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, exercise:, user:)
        create :mentor_discussion, student: user, solution:, status: :finished

        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, exercise:, user:)
        create :mentor_discussion, student: user, solution:, status: :awaiting_student

        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, exercise:, user:)
        create :mentor_request, student: user, solution:, status: :pending

        use_capybara_host do
          sign_in!(user)
          visit journey_url

          assert_text started_at.strftime("%d %b %Y")
          assert_text "When you joined the Ruby Track"
          assert_text "1 Mentoring session completed"
          assert_text "You have 1 discussion in progress and 1 solution in the queue."

          assert_text "You started working through the Ruby Track 9 years ago."
        end
      end

      test "user sees zero state for track learning" do
        user = create :user
        track = create :track
        create(:user_track, user:, track:)

        use_capybara_host do
          sign_in!(user)
          visit journey_url

          assert_text "You have none in progress and none in the queue"
        end
      end

      test "user sees zero state for mentoring" do
        user = create :user
        track = create :track
        create(:user_track, user:, track:)

        use_capybara_host do
          sign_in!(user)
          visit journey_url

          assert_text "You haven't mentored anyone yet"
          assert_link "Try mentoring", href: mentoring_path
        end
      end

      test "user sees zero state for contributing" do
        user = create :user
        track = create :track
        create(:user_track, user:, track:)

        use_capybara_host do
          sign_in!(user)
          visit journey_url

          assert_text "You haven't contributed to Exercism yet"
          assert_link "See how you can contribute", href: contributing_root_path
        end
      end
    end
  end
end
