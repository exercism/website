require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Components
  module Journey
    class ReputationTest < ApplicationSystemTestCase
      include CapybaraHelpers
      include ActionView::Helpers::SanitizeHelper

      test "shows contribution" do
        user = create :user
        track = create :track, title: "Ruby"
        exercise = create(:concept_exercise, track:)
        token = create :user_code_contribution_reputation_token,
          user:,
          level: :large,
          track:,
          exercise:,
          created_at: 1.day.ago,
          earned_on: 1.day.ago,
          external_url: "https://test.exercism.org/token"

        use_capybara_host do
          sign_in!(user)
          visit reputation_journey_path

          assert_text "Showing 1 contribution"
          assert_link strip_tags(token.text), href: "https://test.exercism.org/token"
          assert_text "Ruby"
          assert_text "yesterday"
          assert_text "+ 30"
          # TODO: Fix how icons are rendered
          assert_css ".reputation-token > img.primary-icon[src='#{exercise.icon_url}']"
        end
      end

      test "paginates contributions" do
        User::ReputationToken::Search.stubs(:default_per).returns(1)
        user = create :user
        review_token = create :user_code_review_reputation_token, user:, created_at: Time.current - 1.day
        contribution_token = create :user_code_contribution_reputation_token, user:, level: :large

        use_capybara_host do
          sign_in!(user)
          visit reputation_journey_path

          assert_text "Showing 2 contributions"
          assert_text strip_tags(contribution_token.text)
          assert_no_text strip_tags(review_token.text)

          click_on "2"

          assert_text strip_tags(review_token.text)
          assert_no_text strip_tags(contribution_token.text)
        end
      end

      test "searches contributions" do
        user = create :user
        track = create :track, title: "Ruby"
        exercise = create :concept_exercise
        contribution_token = create(:user_code_contribution_reputation_token,
          user:,
          level: :large,
          exercise:)
        review_token = create(:user_code_review_reputation_token,
          user:,
          track:,
          exercise:)

        use_capybara_host do
          sign_in!(user)
          visit reputation_journey_path
          fill_in "Search by contribution name", with: "Ruby"
        end

        assert_text strip_tags(review_token.text)
        assert_no_text strip_tags(contribution_token.text)
      end

      test "filters contributions" do
        user = create :user
        contribution_token = create(:user_exercise_contribution_reputation_token, user:)
        review_token = create(:user_code_review_reputation_token, user:)

        use_capybara_host do
          sign_in!(user)
          visit reputation_journey_path
          click_on "Category"
          find("label", text: "Contributing to Exercises").click

          assert_no_text strip_tags(review_token.text)
          assert_text strip_tags(contribution_token.text)
        end
      end
    end
  end
end
