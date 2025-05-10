require "application_system_test_case"

module Components
  class BegModalTest < ApplicationSystemTestCase
    CANARY_TEXT = "We need your help!".freeze

    test "shows to basic user" do
      user = setup_user

      use_capybara_host do
        Exercism.without_bullet do
          sign_in!(user)
          visit dashboard_path

          assert_text CANARY_TEXT
          assert_text "Most people who use Exercism can't afford to donate."
        end
      end
    end

    test "shows to legacy donor" do
      user = setup_user
      User.any_instance.stubs(total_donated_in_dollars: 1)

      use_capybara_host do
        Exercism.without_bullet do
          sign_in!(user)
          visit dashboard_path

          assert_text CANARY_TEXT
          assert_text "You're one of the few people who have donated to Exercism"
        end
      end
    end

    test "doesn't show to someone with too few solutions" do
      user = setup_user
      user.solutions.last.destroy

      use_capybara_host do
        Exercism.without_bullet do
          sign_in!(user)
          visit dashboard_path

          refute_text CANARY_TEXT
        end
      end
    end

    test "doesn't show to active subscriber" do
      user = setup_user
      User.any_instance.stubs(current_subscription?: true)

      use_capybara_host do
        Exercism.without_bullet do
          sign_in!(user)
          visit dashboard_path

          refute_text CANARY_TEXT
        end
      end
    end

    test "doesn't show to recent donor" do
      user = setup_user
      User.any_instance.stubs(donated_in_last_35_days?: true)

      use_capybara_host do
        Exercism.without_bullet do
          sign_in!(user)
          visit dashboard_path

          refute_text CANARY_TEXT
        end
      end
    end

    def setup_user
      create(:user).tap do |user|
        5.times { create :practice_solution, user: }
        create :submission, solution: Solution.last
      end
    end
  end
end
