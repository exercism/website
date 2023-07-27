require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Settings
    class UserChangesCommentsPrefrenceTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user updates comments preference" do
        user = create :user

        use_capybara_host do
          sign_in!(user)

          visit user_preferences_settings_path
          find('label', text: I18n.t('user_preferences.allow_comments_on_published_solutions')).click
          click_on "Change preferences"

          assert_text "Your preferences have been updated"
        end
      end

      test "user sees manage existing solutions bit" do
        solution = create :practice_solution, :published
        create :user_track, user: solution.user, track: solution.track

        use_capybara_host do
          sign_in!(solution.user)

          visit user_preferences_settings_path

          assert_text "Allow comments on all existing solutions"
          assert_text "Disable comments on all existing solutions"
        end
      end
      test "user sees comment status phrase none" do
        solution = create :practice_solution, :published, allow_comments: false
        solution = create :practice_solution, :published, allow_comments: false
        solution = create :practice_solution, :published, allow_comments: false

        use_capybara_host do
          sign_in!(solution.user)

          visit user_preferences_settings_path

          assert_text "Currently, people can comment on none of your published solutions."
        end
      end
      test "user sees comment status phrase all" do
        solution = create :practice_solution, :published, allow_comments: true
        solution = create :practice_solution, :published, allow_comments: true
        solution = create :practice_solution, :published, allow_comments: true

        use_capybara_host do
          sign_in!(solution.user)

          visit user_preferences_settings_path

          assert_text "Currently, people can comment on none of your published solutions."
        end
      end
      test "user sees correct fraction number as comment status phrase" do
        solution = create :practice_solution, :published, allow_comments: true
        solution = create :practice_solution, :published, allow_comments: false
        solution = create :practice_solution, :published, allow_comments: false

        use_capybara_host do
          sign_in!(solution.user)

          visit user_preferences_settings_path

          assert_text "Currently, people can comment on 1/3 of your published solutions."
        end
      end
    end
  end
end
