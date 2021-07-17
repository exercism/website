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

      create :user_track, user: user, track: track

      use_capybara_host do
        sign_in!(user)

        visit dashboard_path
        assert_text "Ruby"
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
      create :user_track_mentorship, user: user, track: track
      create :mentor_discussion, mentor: user, status: :awaiting_student
      create :mentor_request, solution: create(:practice_solution, track: track)

      use_capybara_host do
        sign_in!(user)

        visit dashboard_path
        assert_text "Your workspace is clear"
      end
    end

    test "with discussion" do
      user = create :user
      track = create :track
      create :user_track_mentorship, user: user, track: track
      discussion = create :mentor_discussion, mentor: user, status: :awaiting_mentor
      create :mentor_request, solution: create(:practice_solution, track: track)

      use_capybara_host do
        sign_in!(user)

        visit dashboard_path
        assert_text discussion.solution.user.handle
      end
    end
  end
end
