require "application_system_test_case"

module Components
  class SenioritySurveyModalTest < ApplicationSystemTestCase
    test "shows it on dashboard page" do
      user = create :user, seniority: nil
      use_capybara_host do
        Exercism.without_bullet do
          sign_in!(user)
          visit dashboard_path

          assert_text "How experienced a developer are you?"
        end
      end
    end

    # TODO: check why this doesn't fail
    test "does not show if seniority is provided -- this should fail" do
      user = create :user, seniority: :mid

      use_capybara_host do
        Exercism.without_bullet do
          sign_in!(user)
          visit dashboard_path

          assert_text "How experienced a developer are you?"
        end
      end
    end
  end
end
