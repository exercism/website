require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class UserViewsContributionsTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "shows building contributions for a user" do
      user = create :user, handle: "author"
      create :user_profile, user: user
      create :user_code_contribution_reputation_token,
        user: user,
        params: {
          repo: "exercism/ruby",
          pr_node_id: SecureRandom.uuid,
          pr_number: "12",
          pr_title: "Fix bugs"
        }

      use_capybara_host do
        sign_in!(user)
        visit contributions_profile_url(user.handle)
      end

      assert_text "author created PR#12 on ruby: Fix bugs"
    end

    test "shows maintaining contributions for a user" do
      user = create :user, handle: "maintainer"
      create :user_profile, user: user
      create :user_code_merge_reputation_token,
        user: user,
        params: {
          repo: "exercism/ruby",
          pr_node_id: SecureRandom.uuid,
          pr_number: "12",
          pr_title: "Fix bugs"
        }

      use_capybara_host do
        sign_in!(user)
        visit contributions_profile_url(user.handle)
      end

      assert_text "maintainer merged PR#12 on ruby: Fix bugs"
    end

    test "shows authorship contributions for a user" do
      user = create :user, handle: "author"
      create :user_profile, user: user
      create :exercise_authorship, author: user

      use_capybara_host do
        sign_in!(user)
        visit contributions_profile_url(user.handle)
      end

      assert_text "Strings"
    end
  end
end
