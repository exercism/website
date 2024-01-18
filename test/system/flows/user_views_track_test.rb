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

        assert_text "Developer happiness"
        assert_text "Ruby puts developer-happiness first. It has an elegant syntax that is natural to read and write."

        assert_text "Metaprogramming magic"
        assert_text "Ruby code can write and invoke Ruby code."

        assert_text "Garbage Collection"
        assert_text "Garbage collection done via mark and sweep, stays out of your way."

        assert_text "Large standard library"
        assert_text "Ruby's standard library provides a wealth of classes utilities for common tasks."

        assert_text "Flexible package manager"
        assert_text "Packages (gems) can be centrally managed, but can also include custom or private gem stores."

        assert_text "Strong, dynamic typing"
        assert_text "Ruby is strong and dynamically typed and supports 'Duck Typing'. Everything in Ruby is an object"
      end
    end

    test "shows concepts preview if track has course" do
      track = create :track, course: true

      use_capybara_host do
        visit track_path(track)

        assert_text "A taste of the concepts you'll cover"
      end
    end

    test "does not show concepts preview if track does not have course" do
      track = create :track, course: false

      use_capybara_host do
        visit track_path(track)

        refute_text "A taste of the concepts you'll cover"
      end
    end

    test "shows syllabus if track has course" do
      track = create :track, course: true
      stub_latest_track_forum_threads(track)

      use_capybara_host do
        visit track_path(track)

        within(".c-track-header") do
          click_on "Learn"
        end
        assert_text "Your journey through Ruby"
      end
    end

    test "shows syllabus if track does not have course but user is track maintainer" do
      track = create :track, course: false
      create(:concept_exercise, status: :wip, track:)
      user = create :user, :maintainer, uid: '256123'
      create(:user_dismissed_introducer, slug: "track-welcome-modal-#{track.slug}", user:)
      create :github_team_member, user_id: user.uid, team_name: track.github_team_name
      create(:user_track, track:, user:)
      create(:hello_world_solution, :completed, track:, user:)
      stub_latest_track_forum_threads(track)

      use_capybara_host do
        sign_in!(user.reload)
        visit track_path(track)

        within(".c-track-header") do
          click_on "Learn"
        end
        assert_text "Your journey through Ruby"
      end
    end
  end
end
