require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Settings
    class UserChangesCommentsPreferenceTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user updates comments preference" do
        user = create :user
        user.preferences.update(allow_comments_on_published_solutions: true)

        use_capybara_host do
          sign_in!(user)
          visit user_preferences_settings_path

          label = find('label', text: I18n.t('user_preferences.allow_comments_on_published_solutions'))
          checkbox = find('#comments-preference-form input[type=checkbox]', visible: false)
          assert checkbox.checked?
          label.click
          refute checkbox.checked?
          click_on "Update preference"
          assert_text "Your preferences have been updated"
        end
      end

      test "user does not see manage existing solutions section" do
        user = create :user

        use_capybara_host do
          sign_in!(user)
          visit user_preferences_settings_path

          refute_text "Allow comments on all existing solutions"
          refute_text "Disable comments on all existing solutions"
        end
      end

      test "user sees manage existing solutions section" do
        solution = create :practice_solution, :published
        create :user_track, user: solution.user, track: solution.track

        use_capybara_host do
          sign_in!(solution.user)
          visit user_preferences_settings_path

          assert_text "Allow comments on all existing solutions"
          assert_text "Disable comments on all existing solutions"

          click_on "Allow comments on all existing solutions"
          assert_text "Your preferences have been updated"

          sleep 5

          click_on "Disable comments on all existing solutions"
          assert_text "Your preferences have been updated"
        end
      end

      test "user sees comment status phrase none" do
        user = create :user
        create(:practice_solution, :published, allow_comments: false, user:)
        create(:practice_solution, :published, allow_comments: false, user:)
        create(:practice_solution, :published, allow_comments: false, user:)

        use_capybara_host do
          sign_in!(user)
          visit user_preferences_settings_path

          assert_text "Currently, people can comment on none of your published solutions."
        end
      end

      test "user sees comment status phrase all" do
        user = create :user
        create(:practice_solution, :published, allow_comments: true, user:)
        create(:practice_solution, :published, allow_comments: true, user:)
        create(:practice_solution, :published, allow_comments: true, user:)

        use_capybara_host do
          sign_in!(user)
          visit user_preferences_settings_path

          assert_text "Currently, people can comment on all of your published solutions."
        end
      end

      test "user sees correct fraction number as comment status phrase" do
        user = create :user
        create(:practice_solution, :published, allow_comments: true, user:)
        create(:practice_solution, :published, allow_comments: true, user:)
        create(:practice_solution, :published, allow_comments: false, user:)

        use_capybara_host do
          sign_in!(user)
          visit user_preferences_settings_path

          assert_text "Currently, people can comment on 2 / 3 of your published solutions."
        end
      end
    end
  end
end
