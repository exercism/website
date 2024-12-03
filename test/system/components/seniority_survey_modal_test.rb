require "application_system_test_case"

module Components
  class SenioritySurveyModalTest < ApplicationSystemTestCase
    CANARY = "We're expanding Exercism to add content relevant".freeze

    test "shows it on dashboard page" do
      user = create :user, seniority: nil
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
      user = create :user, seniority: :mid
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
      user = create :user, seniority: nil

      use_capybara_host do
        Exercism.without_bullet do
          sign_in!(user)
          visit dashboard_path

          refute_text CANARY
        end
      end
    end
  end
end
