require "application_system_test_case"

module Flows
  class UserOnboardingTest < ApplicationSystemTestCase
    test "user is onboarded before being able to do anything on the website" do
      user = create :user, :not_onboarded
      sign_in!(user)

      visit root_path
      check "Accept Terms of Service"
      check "Accept Privacy Policy"
      click_on "Submit"

      assert_text "Welcome to Exercism v3"
    end
  end
end
