require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Contributing
    class UserViewsContributorsListTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user views contributor list" do
        create :user
        contributor = create :user, handle: "contributor"
        token = create :user_reputation_token, user: contributor, value: 10
        User::ReputationPeriod::MarkForToken.(token)
        User::ReputationPeriod::Sweep.()

        use_capybara_host do
          visit contributing_contributors_path

          assert_text "contributor"
          assert_text "1 PR created"
          assert_text "12"
        end
      end

      test "user filters by period" do
        create :user
        contributor = create :user, handle: "contributor"
        week_token = create :user_reputation_token, user: contributor, value: 10, earned_on: Time.zone.today
        User::ReputationPeriod::MarkForToken.(week_token)
        month_token = create :user_reputation_token, user: contributor, value: 10, earned_on: 2.months.ago
        User::ReputationPeriod::MarkForToken.(month_token)
        User::ReputationPeriod::Sweep.()

        use_capybara_host do
          visit contributing_contributors_path
          click_on "This week"

          assert_text "1 PR created"
        end
      end

      test "user filters by category" do
        create :user
        contributor = create :user, handle: "contributor"
        building_token = create :user_reputation_token, user: contributor, value: 10
        User::ReputationPeriod::MarkForToken.(building_token)
        maintaining_token = create :user_code_merge_reputation_token, user: contributor, value: 10
        User::ReputationPeriod::MarkForToken.(maintaining_token)
        User::ReputationPeriod::Sweep.()

        use_capybara_host do
          visit contributing_contributors_path
          click_on "All categories"
          find("label", text: "Maintaining").click

          assert_text "1 PR merged"
          assert_no_text "1 PR created"
        end
      end

      test "user filters by track" do
        create :user
        contributor = create :user, handle: "contributor"
        ruby = create :track, title: "Ruby", slug: "ruby"
        ruby_token = create :user_reputation_token, user: contributor, value: 10, track: ruby
        User::ReputationPeriod::MarkForToken.(ruby_token)
        go = create :track, title: "Go", slug: "go"
        go_token = create :user_reputation_token, user: contributor, value: 10, track: go
        User::ReputationPeriod::MarkForToken.(go_token)
        User::ReputationPeriod::Sweep.()

        use_capybara_host do
          visit contributing_contributors_path
          click_on "All Tracks"
          find("label", text: "Go").click

          assert_text "1 PR created"
          within(".c-search-bar") { assert_text "Go" }
        end
      end

      test "user filters by url parameters" do
        create :user
        contributor = create :user, handle: "contributor"
        ruby = create :track, title: "Ruby", slug: "ruby"
        ruby_token = create :user_reputation_token, user: contributor, value: 10, track: ruby
        User::ReputationPeriod::MarkForToken.(ruby_token)
        go = create :track, title: "Go", slug: "go"
        go_token = create :user_reputation_token, user: contributor, value: 10, track: go
        User::ReputationPeriod::MarkForToken.(go_token)
        User::ReputationPeriod::Sweep.()

        use_capybara_host do
          visit contributing_contributors_path(track_slug: "go")

          assert_text "1 PR created"
          within(".c-search-bar") { assert_text "Go" }
        end
      end
    end
  end
end
