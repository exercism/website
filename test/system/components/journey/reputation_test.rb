require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Components
  module Journey
    class ReputationTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "shows contribution" do
        user = create :user
        track = create :track, title: "Ruby"
        token = create :user_reputation_token,
          user: user,
          reason: "contributed_code/major",
          track: track,
          created_at: 1.day.ago,
          value: 15,
          external_link: "https://test.exercism.io/token"

        use_capybara_host do
          sign_in!(user)
          visit reputation_journey_path

          assert_text "Showing 1 contribution"
          assert_link "You contributed code", href: "https://test.exercism.io/token"
          assert_text "Ruby"
          assert_text "a day ago"
          assert_text "+ 15"
          assert_icon track.icon_name
          assert_icon token.icon_name
        end
      end

      test "paginates contributions" do
        API::ReputationController.stubs(:per).returns(1)
        user = create :user
        create :user_reputation_token,
          user: user,
          reason: "contributed_code/major",
          category: "building"
        create :user_reputation_token,
          user: user,
          reason: "reviewed_code",
          category: "authoring"

        use_capybara_host do
          sign_in!(user)
          visit reputation_journey_path
          click_on "2"
        end

        assert_text "You reviewed a Pull Request"
        assert_no_text "You contributed code"
      end

      test "searches contributions" do
        user = create :user
        track = create :track, title: "Ruby"
        exercise = create :concept_exercise
        create :user_reputation_token,
          user: user,
          reason: "contributed_code/major",
          category: "building",
          exercise: exercise
        create :user_reputation_token,
          user: user,
          reason: "reviewed_code",
          category: "authoring",
          track: track,
          exercise: exercise

        use_capybara_host do
          sign_in!(user)
          visit reputation_journey_path
          fill_in "Search for a contribution", with: "Ruby"
        end

        assert_no_text "You contributed code"
        assert_text "You reviewed a Pull Request"
      end

      test "filters contributions" do
        user = create :user
        create :user_reputation_token,
          user: user,
          reason: "contributed_code/major",
          category: "building"
        create :user_reputation_token,
          user: user,
          reason: "reviewed_code",
          category: "authoring"

        use_capybara_host do
          sign_in!(user)
          visit reputation_journey_path
          click_on "Filter by"
          choose "Contributing to Exercises"
          click_on "Apply"

          assert_text "You reviewed a Pull Request"
          assert_no_text "You contributed code"
        end
      end

      private
      def assert_icon(name)
        assert_css "use[*|href=\"##{name}\"]"
      end
    end
  end
end
