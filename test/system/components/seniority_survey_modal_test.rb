require "application_system_test_case"

module Components
  class SenioritySurveyModalTest < ApplicationSystemTestCase
    CANARY = "We're expanding Exercism to add content relevant".freeze

    test "shows it on dashboard page" do
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

    test "does not show if welcome modal shows" do
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
