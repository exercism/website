require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class UserViewsDashboardTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "shows last touched tracks" do
      user = create :user
      nim = create :track, :random_slug, title: "Nim"
      ruby = create :track, :random_slug, title: "Ruby"
      kotlin = create :track, :random_slug, title: "Kotlin"
      elixir = create :track, :random_slug, title: "Elixir"
      create :user_track, track: nim, user: user, last_touched_at: 4.days.ago
      create :user_track, track: kotlin, user: user, last_touched_at: 3.days.ago
      create :user_track, track: ruby, user: user, last_touched_at: 2.days.ago
      create :user_track, track: elixir, user: user, last_touched_at: 1.day.ago

      use_capybara_host do
        sign_in!(user)
        visit dashboard_path

        within(".tracks-section .tracks") do
          assert_selector('.track', count: 3)

          expected_order = %w[Elixir Ruby Kotlin]
          find_all(".track .info .title").map.with_index do |_track, i|
            assert_text expected_order[i]
          end
        end
      end
    end

    test "shows latest revealed badges" do
      user = create :user

      %i[member rookie begetter researcher moss contributor architect].each do |badge_name|
        badge = create("#{badge_name}_badge".to_sym)
        create :user_acquired_badge, user: user, badge: badge, revealed: true
      end

      # Ignore latest unrevealed badges
      create :user_acquired_badge, user: user, badge: create(:lackadaisical_badge), revealed: false
      create :user_acquired_badge, user: user, badge: create(:whatever_badge), revealed: false

      use_capybara_host do
        sign_in!(user)
        visit dashboard_path

        within(".badges") do
          assert_selector('.c-badge-medallion', count: 4)
          assert_text "+ 3 more"

          expected_order = %w[researcher moss contributor architect]
          find_all("c-badge-medallion --legendary").map.with_index do |_, i|
            assert_selector("img[alt*='#{expected_order[i]}']")
          end
        end
      end
    end
  end
end
