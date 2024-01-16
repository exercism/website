require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Pages
  class DasboardTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "zero states" do
      user = create :user, :not_mentor

      use_capybara_host do
        sign_in!(user)

        visit dashboard_path
        assert_text "You've not joined a track yet"
        assert_text "Become a mentor"
      end
    end

    test "with a track" do
      user = create :user
      track = create :track, title: "Ruby"

      create(:user_track, user:, track:)

      use_capybara_host do
        sign_in!(user)

        visit dashboard_path

        within "#page-dashboard" do
          assert_text "Ruby"
          assert_text "Your Tracks 1"
          assert_link "Discover more tracks"
        end
      end
    end

    test "with three track" do
      user = create :user

      %w[nim kotlin prolog].each do |slug|
        create :user_track, user:, track: create(:track, slug:)
      end

      use_capybara_host do
        sign_in!(user)

        visit dashboard_path

        within "#page-dashboard" do
          assert_text "Your Tracks 3"
          assert_link "Discover more tracks"
        end
      end
    end

    test "with four track" do
      user = create :user

      ut_1 = create :user_track, last_touched_at: Time.current - 1.day, user:, track: create(:track, slug: "nim")
      ut_2 = create :user_track, last_touched_at: Time.current - 2.days, user:, track: create(:track, slug: "prolog")
      ut_3 = create :user_track, last_touched_at: Time.current, user:, track: create(:track, slug: "swift")
      ut_4 = create :user_track, last_touched_at: Time.current + 1.day, user:, track: create(:track, slug: "kotlin")

      use_capybara_host do
        sign_in!(user)

        visit dashboard_path

        within "#page-dashboard" do
          assert_text ut_4.track.title
          assert_text ut_3.track.title
          assert_text ut_1.track.title
          refute_text ut_2.track.title

          assert_text "Your Tracks 4"
          assert_link "View all your tracks"
        end
      end
    end

    test "with no discussions or requests" do
      user = create :user

      use_capybara_host do
        sign_in!(user)

        visit dashboard_path
        assert_text "No mentoring discussions left"
      end
    end

    test "with requests but no discussions" do
      user = create :user
      track = create :track
      create(:user_track_mentorship, user:, track:)
      create :mentor_discussion, mentor: user, status: :awaiting_student
      create :mentor_request, solution: create(:practice_solution, track:)

      use_capybara_host do
        sign_in!(user)

        visit dashboard_path
        assert_text "Your workspace is clear"
      end
    end

    test "with discussion" do
      user = create :user
      track = create :track
      create(:user_track_mentorship, user:, track:)
      discussion = create :mentor_discussion, mentor: user, status: :awaiting_mentor
      create :mentor_request, solution: create(:practice_solution, track:)

      use_capybara_host do
        sign_in!(user)

        visit dashboard_path
        assert_text discussion.solution.user.handle
      end
    end
  end
end
