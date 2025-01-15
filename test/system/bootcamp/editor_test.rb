require "application_system_test_case"

module Bootcamp
  class EditorTest < ApplicationSystemTestCase
    test "shows to basic user" do
      email = "#{SecureRandom.uuid}@test.com"
      ubd = create :user_bootcamp_data, email:, paid_at: Time.current
      user = create(:user, email:)
      project = create :bootcamp_project
      exercise = create :bootcamp_exercise, bootcamp_project: project

      # Always does this once by default anyway
      User::Bootcamp::SubscribeToOnboardingEmails.expects(:defer).with(ubd).twice

      User::Bootstrap.(user)
      assert user.reload.bootcamp_attendee?

      use_capybara_host do
        sign_in!(user)
        visit bootcamp_project_exercise_url(project, exercise)

        assert_text "Welcome to the Exercism Bootcamp!"
      end
    end
  end
end
