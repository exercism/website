require "application_system_test_case"
require_relative "../../support/capybara_helpers"
require_relative "../../support/websockets_helpers"

module Flows
  class UserLoadsReputationTest < ApplicationSystemTestCase
    include CapybaraHelpers
    include WebsocketsHelpers

    test "user views reputation" do
      user = create :user
      external_url = "https://github.com/exercism/ruby/pulls/120"
      create :user_code_review_reputation_token,
        user: user,
        created_at: 2.days.ago,
        value: 50,
        seen: false,
        params: {
          external_url: external_url,
          repo: "ruby/pulls",
          pr_node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
          pr_number: 120,
          pr_title: "I did something"
        }

      use_capybara_host do
        sign_in!(user)
        visit dashboard_path
        find(".c-primary-reputation").click

        assert_css ".--notification"
        assert_link "You reviewed PR#120 on pulls: I did something", href: external_url
        assert_text "2 days ago"
        assert_text "50"
        assert_link "See how you earned all your reputation", href: reputation_journey_url
      end
    end

    test "mark token as seen on hover" do
      user = create :user
      create :user_code_review_reputation_token,
        user: user,
        created_at: 2.days.ago,
        value: 50,
        seen: false,
        params: {
          external_url: "https://github.com/exercism/ruby/pulls/120",
          repo: "ruby/pulls",
          pr_node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
          pr_number: 120,
          pr_title: "Something else"
        }

      use_capybara_host do
        sign_in!(user)
        visit dashboard_path
        find(".c-primary-reputation").click
        first('li[role="menuitem"]').hover
      end

      assert_no_css ".indicator.unseen"
      assert_css ".indicator.seen"
    end

    test "mark token as seen on focus" do
      user = create :user
      create :user_code_review_reputation_token,
        user: user,
        created_at: 2.days.ago,
        value: 50,
        seen: false,
        params: {
          external_url: "https://github.com/exercism/ruby/pulls/120",
          repo: "ruby/pulls",
          pr_node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
          pr_number: 120,
          pr_title: "Something else"
        }

      use_capybara_host do
        sign_in!(user)
        visit dashboard_path
        find(".c-primary-reputation").click
        assert_text "You reviewed PR#120"
        find(".c-primary-reputation").send_keys(:arrow_down)
      end

      assert_no_css ".indicator.unseen"
      assert_css ".indicator.seen"
    end

    test "refetches on websocket notification" do
      user = create :user

      use_capybara_host do
        sign_in!(user)
        visit dashboard_path
        wait_for_websockets
        create :user_code_review_reputation_token,
          user: user,
          created_at: 2.days.ago,
          params: {
            repo: "ruby/pulls",
            pr_node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
            pr_number: 120,
            pr_title: "Something else"
          }
        ReputationChannel.broadcast_changed!(user)
        within(".c-primary-reputation") { assert_text "5" }
        assert_css ".--notification.unseen"
        find(".c-primary-reputation").click

        assert_text "You reviewed PR#120 on pulls: Something else"
      end
    end
  end
end
