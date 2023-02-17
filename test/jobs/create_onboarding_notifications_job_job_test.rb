require "test_helper"

class CreateOnboardingNotificationsJobTest < ActiveJob::TestCase
  test "sends onboarding community notification" do
    skip

    # TODO
    CreateOnboardingNotificationsJob.perform_now
  end

  test "sends onboarding fundraising notification" do
    skip

    # TODO
    CreateOnboardingNotificationsJob.perform_now
  end
end
