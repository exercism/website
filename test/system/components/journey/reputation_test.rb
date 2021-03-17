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
        exercise = create :concept_exercise, track: track
        token = create :user_code_contribution_reputation_token,
          user: user,
          level: :major,
          track: track,
          exercise: exercise,
          created_at: 1.day.ago,
          external_link: "https://test.exercism.io/token"

        use_capybara_host do
          sign_in!(user)
          visit reputation_journey_path

          assert_text "Showing 1 contribution"
          assert_link strip_tags(token.text), href: "https://test.exercism.io/token"
          assert_text "Ruby"
          assert_text "a day ago"
          assert_text "+ 30"
          # TODO: Fix how icons are rendered
          assert_css ".reputation-token > img.primary-icon[src='#{exercise.icon_url}']"
        end
      end

      test "paginates contributions" do
        User::ReputationToken::Search.stubs(:default_per).returns(1)
        user = create :user
        review_token = create :user_code_review_reputation_token, user: user
        contribution_token = create :user_code_contribution_reputation_token, user: user, level: :major

        use_capybara_host do
          sign_in!(user)
          visit reputation_journey_path
          click_on "2"
        end

        assert_text strip_tags(review_token.text)
        assert_no_text strip_tags(contribution_token.text)
      end

      test "sorts contributions" do
        User::ReputationToken::Search.stubs(:default_per).returns(1)
        user = create :user
        contribution_token = create :user_code_contribution_reputation_token,
          user: user,
          level: :major,
          created_at: 2.days.ago
        review_token = create :user_code_review_reputation_token, user: user, created_at: 1.day.ago

        use_capybara_host do
          sign_in!(user)
          visit reputation_journey_path
          select "Sort by Newest First"

          # TODO: This test isn't testing what the title says it should test
          assert_text strip_tags(review_token.text)
          assert_no_text strip_tags(contribution_token.text)
        end
      end

      test "searches contributions" do
        user = create :user
        track = create :track, title: "Ruby"
        exercise = create :concept_exercise
        contribution_token = create :user_code_contribution_reputation_token,
          user: user,
          level: :major,
          exercise: exercise
        review_token = create :user_code_review_reputation_token,
          user: user,
          track: track,
          exercise: exercise

        use_capybara_host do
          sign_in!(user)
          visit reputation_journey_path
          fill_in "Search for a contribution", with: "Ruby"
        end

        assert_text strip_tags(review_token.text)
        assert_no_text strip_tags(contribution_token.text)
      end

      test "filters contributions" do
        user = create :user
        contribution_token = create :user_exercise_contribution_reputation_token, user: user
        review_token = create :user_code_review_reputation_token, user: user

        use_capybara_host do
          sign_in!(user)
          visit reputation_journey_path
          click_on "Filter by"
          choose "Contributing to Exercises"
          click_on "Apply"

          assert_no_text strip_tags(review_token.text)
          assert_text strip_tags(contribution_token.text)
        end
      end
    end
  end
end
