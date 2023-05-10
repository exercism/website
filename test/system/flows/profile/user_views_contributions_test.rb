require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Profile
    class UserViewsContributionsTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "shows contributions for a user when logged out" do
        User::ReputationToken::Search.stubs(:default_per).returns(1)
        user = create :user, handle: "author"
        create(:user_profile, user:)
        create :user_code_contribution_reputation_token,
          user:,
          params: {
            repo: "exercism/ruby",
            pr_node_id: SecureRandom.uuid,
            pr_number: "12",
            pr_title: "Fix bugs",
            merged_at: Time.parse('2020-02-02T02:03:01Z').utc
          }
        create :user_code_contribution_reputation_token,
          user:,
          params: {
            repo: "exercism/ruby",
            pr_node_id: SecureRandom.uuid,
            pr_number: "13",
            pr_title: "Fix bugs",
            merged_at: Time.parse('2020-02-02T02:03:01Z').utc
          }

        use_capybara_host do
          visit contributions_profile_url(user.handle)
          click_on "Next"
        end

        assert_no_text "Created PR#13 on ruby: Fix bugs"
        assert_text "Created PR#12 on ruby: Fix bugs"
      end

      test "shows building contributions for a user" do
        user = create :user, handle: "author"
        create(:user_profile, user:)
        create :user_code_contribution_reputation_token,
          user:,
          params: {
            repo: "exercism/ruby",
            pr_node_id: SecureRandom.uuid,
            pr_number: "12",
            pr_title: "Fix bugs",
            merged_at: Time.parse('2020-02-02T02:03:01Z').utc
          }

        use_capybara_host do
          sign_in!(user)
          visit contributions_profile_url(user.handle)
        end

        assert_text "Created PR#12 on ruby: Fix bugs"
      end

      test "shows maintaining contributions for a user" do
        user = create :user, handle: "maintainer"
        create(:user_profile, user:)
        create :user_code_merge_reputation_token,
          user:,
          params: {
            repo: "exercism/ruby",
            pr_node_id: SecureRandom.uuid,
            pr_number: "12",
            pr_title: "Fix bugs",
            merged_at: Time.parse('2020-02-02T02:03:01Z').utc
          }

        use_capybara_host do
          sign_in!(user)
          visit contributions_profile_url(user.handle)
        end

        assert_text "Merged PR#12 on ruby: Fix bugs"
      end

      test "shows authorship contributions for a user" do
        user = create :user, handle: "author"
        exercise = create :concept_exercise
        create(:user_profile, user:)
        create :user_exercise_author_reputation_token,
          user:,
          params: {
            authorship: create(:exercise_authorship, author: user, exercise:)
          }

        use_capybara_host do
          sign_in!(user)
          visit contributions_profile_url(user.handle)
          click_on "Authoring"
        end

        assert_link "Strings", href: track_exercise_path(exercise.track, exercise.slug)
      end

      test "shows other contributions for a user" do
        user = create :user, handle: "maintainer"
        create(:user_profile, user:)
        create :user_arbitrary_reputation_token,
          user:,
          params: {
            arbitrary_value: 19,
            arbitrary_reason: 'For helping troubleshoot'
          }

        use_capybara_host do
          sign_in!(user)
          visit contributions_profile_url(user.handle)
        end

        assert_text "For helping troubleshoot"
      end
    end
  end
end
