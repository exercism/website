require "application_system_test_case"

module Components
  class BegModalTest < ApplicationSystemTestCase
    CANARY_TEXT = "We need your help!".freeze

    test "shows to basic user" do
      user = create :user

      use_capybara_host do
        sign_in!(user)
        visit dashboard_path

        assert_text CANARY_TEXT
        assert_text "Most people who use Exercism can't afford to donate."
      end
    end

    test "shows to legacy donor" do
      user = create :user
      User.any_instance.stubs(total_donated_in_dollars: 1)

      use_capybara_host do
        sign_in!(user)
        visit dashboard_path

        assert_text CANARY_TEXT
        assert_text "You're one of the few people who have donated to Exercism"
      end
    end

    test "doesn't show to active subscriber" do
      user = create :user
      User.any_instance.stubs(current_subscription: true)

      use_capybara_host do
        sign_in!(user)
        visit dashboard_path

        refute_text CANARY_TEXT
      end
    end

    test "doesn't show to recent donor" do
      user = create :user
      User.any_instance.stubs(donated_in_last_35_days?: true)

      use_capybara_host do
        sign_in!(user)
        visit dashboard_path

        refute_text CANARY_TEXT
      end
    end
  end
end
