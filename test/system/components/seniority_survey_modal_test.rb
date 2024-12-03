require "application_system_test_case"

module Components
  class SenioritySurveyModalTest < ApplicationSystemTestCase
    test "shows it on dashboard page" do
      user = create :user, seniority: nil
      create(:user_dismissed_introducer, user:, slug: "welcome-modal")

      use_capybara_host do
        Exercism.without_bullet do
          sign_in!(user)
          visit dashboard_path

          assert_text "How experienced a developer are you?"
        end
      end
    end

    test "does not show if seniority is provided -- this should fail" do
      user = create :user, seniority: :mid
      create(:user_dismissed_introducer, user:, slug: "welcome-modal")

      use_capybara_host do
        Exercism.without_bullet do
          sign_in!(user)
          visit dashboard_path

          refute_text "How experienced a developer are you?"
        end
      end
    end
  end
end
