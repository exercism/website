require "application_system_test_case"

module Components
  class ReturningUserModalTest < ApplicationSystemTestCase
    CANARY = "where you are in your coding journey?".freeze

    test "shows it on the dashboard" do
      user = create :user, seniority: nil, created_at: signed_up_before_cutoff
      create(:user_dismissed_introducer, user:, slug: "welcome-modal")

      use_capybara_host do
        Exercism.without_bullet do
          sign_in!(user)
          visit dashboard_path

          assert_text CANARY
        end
      end
    end

    test "a developer is thanked and saved as senior" do
      user = create :user, seniority: nil, created_at: signed_up_before_cutoff
      create(:user_dismissed_introducer, user:, slug: "welcome-modal")

      use_capybara_host do
        Exercism.without_bullet do
          sign_in!(user)
          visit dashboard_path

          find("label", text: "I'm a developer").click
          click_on "Save my choice"

          assert_text "Thanks!"
          refute_text CANARY
        end
      end

      assert_equal :senior, user.reload.seniority
    end

    test "a beginner is offered Jiki and saved as an absolute beginner" do
      user = create :user, seniority: nil, created_at: signed_up_before_cutoff
      create(:user_dismissed_introducer, user:, slug: "welcome-modal")

      use_capybara_host do
        Exercism.without_bullet do
          sign_in!(user)
          visit dashboard_path

          find("label", text: "I'm a beginner").click
          click_on "Save my choice"

          assert_text "We've designed a new platform for your level!"
          find("#returning-user-modal .later-link").click
          refute_text "We've designed a new platform for your level!"
        end
      end

      assert_equal :absolute_beginner, user.reload.seniority
    end

    test "does not show if seniority is provided" do
      user = create :user, seniority: :mid, created_at: signed_up_before_cutoff
      create(:user_dismissed_introducer, user:, slug: "welcome-modal")

      use_capybara_host do
        Exercism.without_bullet do
          sign_in!(user)
          visit dashboard_path

          refute_text CANARY
        end
      end
    end

    test "does not show to a user who signed up after the sign-up page asked for seniority" do
      user = create :user, seniority: nil
      create(:user_dismissed_introducer, user:, slug: "welcome-modal")

      use_capybara_host do
        Exercism.without_bullet do
          sign_in!(user)
          visit dashboard_path

          refute_text CANARY
        end
      end
    end

    test "does not show if the welcome modal shows" do
      user = create :user, seniority: nil, created_at: signed_up_before_cutoff

      use_capybara_host do
        Exercism.without_bullet do
          sign_in!(user)
          visit dashboard_path

          refute_text CANARY
        end
      end
    end

    private
    def signed_up_before_cutoff
      User::DetermineIfOnboardingAsksSeniority::SIGN_UP_ASKS_SENIORITY_FROM - 1.day
    end
  end
end
