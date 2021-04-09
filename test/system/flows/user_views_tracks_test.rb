require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class UserViewsTracksTest < ApplicationSystemTestCase
    include CapybaraHelpers

    setup do
      sign_in!
    end

    test "shows track information" do
      user = create :user
      ruby = create :track, :random_slug
      create :track, :random_slug
      create :track, :random_slug
      create :user_track, track: ruby, user: user, updated_at: 2.days.ago

      use_capybara_host do
        sign_in!(user)
        visit tracks_path

        assert_text "Last touched 2 days ago"
        assert_text "Showing all 3 tracks"
      end
    end

    test "separates tracks into joined and unjoined" do
      user = create :user
      ruby = create :track, :random_slug, title: "Ruby"
      create :track, :random_slug, title: "Go"
      create :user_track, track: ruby, user: user

      use_capybara_host do
        sign_in!(user)
        visit tracks_path

        within(".joined-tracks") { assert_text "Ruby" }
        within(".unjoined-tracks") { assert_text "Go" }
      end
    end

    test "filter by track title" do
      create :track, :random_slug, title: "Ruby"
      create :track, :random_slug, title: "Go"

      use_capybara_host do
        sign_in!
        visit tracks_path
        fill_in "Search language tracks", with: "Go"

        assert_selector(".c-tracks-list .--track", count: 1)
        assert_text "Go", within: ".--track"
      end
    end

    test "filter by tag" do
      create :track, :random_slug, title: "Ruby", tags: ["paradigm/object_oriented", "typing/dynamic"]
      create :track, :random_slug, title: "Go", tags: ["paradigm/object_oriented", "typing/static"]

      use_capybara_host do
        sign_in!
        visit tracks_path
        click_on "Filter by"
        check "Object-oriented"
        check "Dynamic"
        click_on "Apply"

        assert_selector(".c-tracks-list .--track", count: 1)
        assert_text "Ruby", within: ".--track"
      end
    end

    test "resets filters" do
      create :track, :random_slug, title: "Ruby", tags: ["paradigm/object_oriented", "typing/dynamic"]
      create :track, :random_slug, title: "Go", tags: ["paradigm/object_oriented", "typing/static"]

      use_capybara_host do
        sign_in!
        visit tracks_path
        click_on "Filter by"
        check "Object-oriented"
        check "Dynamic"
        click_on "Apply"
        click_on "Reset filters"

        assert_text "Ruby"
        assert_text "Go"
      end
    end

    test "shows empty state" do
      use_capybara_host do
        sign_in!
        visit tracks_path

        assert_text "No results found"
      end
    end
  end
end
