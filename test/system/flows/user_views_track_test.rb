require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class UserViewsTrackTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "shows about information" do
      track = create :track

      use_capybara_host do
        visit track_path(track)

        assert_text "Ruby is a dynamic, open source programming language with a focus on simplicity and productivity."
      end
    end

    test "shows key features" do
      track = create :track

      use_capybara_host do
        visit track_path(track)

        assert_text "Modern"
        assert_text "Ruby is a modern, object-oriented language."

        assert_text "Fun"
        assert_text "Ruby is fun to use!"

        assert_text "Full-featured"
        assert_text "Ruby is packed with built-in useful stuff."

        assert_text "Easy to learn"
        assert_text "Ruby is easy to learn."

        assert_text "Dynamic"
        assert_text "Ruby is very dynamic."

        assert_text "Expressive"
        assert_text "Ruby code can be very expressive."
      end
    end

    test "shows concepts preview if track has course" do
      track = create :track, course: true

      use_capybara_host do
        visit track_path(track)

        assert_text "A taste of the concepts you’ll cover"
      end
    end

    test "does not show concepts preview if track does not have course" do
      track = create :track, course: false

      use_capybara_host do
        visit track_path(track)

        refute_text "A taste of the concepts you’ll cover"
      end
    end

    test "shows syllabus if track has course" do
      track = create :track, course: true
      stub_latest_track_forum_threads(track)

      use_capybara_host do
        visit track_path(track)

        click_on "Syllabus"
        assert_text "Your journey through Ruby"
      end
    end

    test "shows syllabus if track does not have course but user is track maintainer" do
      track = create :track, course: false
      create(:concept_exercise, status: :wip, track:)
      user = create :user, :maintainer, uid: '256123'
      create :github_team_member, user_id: user.uid, team_name: track.github_team_name
      create(:user_track, track:, user:)
      create(:hello_world_solution, :completed, track:, user:)
      stub_latest_track_forum_threads(track)

      use_capybara_host do
        sign_in!(user.reload)
        visit track_path(track)

        click_on "Syllabus"
        assert_text "Your journey through Ruby"
      end
    end
  end
end
