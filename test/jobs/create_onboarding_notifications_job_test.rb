require "test_helper"

class CreateOnboardingNotificationsJobTest < ActiveJob::TestCase
  test "sends onboarding community notification to correct users" do
    user_1 = create :user, created_at: Time.current - 1.1.days
    user_2 = create :user, created_at: Time.current - 1.5.days
    user_3 = create :user, created_at: Time.current - 1.9.days

    user_4 = create :user, created_at: Time.current - 0.1.days # Sanity check: too soon
    user_5 = create :user, created_at: Time.current - 2.1.days # Sanity check: too late

    User::Notification::Create.expects(:call).with(user_1, :onboarding_community).once
    User::Notification::Create.expects(:call).with(user_2, :onboarding_community).once
    User::Notification::Create.expects(:call).with(user_3, :onboarding_community).once
    User::Notification::Create.expects(:call).with(user_4, :onboarding_community).never
    User::Notification::Create.expects(:call).with(user_5, :onboarding_community).never

    CreateOnboardingNotificationsJob.perform_now
  end

  test "sends onboarding fundraising notification to correct users" do
    user_1 = create :user, created_at: Time.current - 3.1.days
    user_2 = create :user, created_at: Time.current - 3.5.days
    user_3 = create :user, created_at: Time.current - 3.9.days

    user_4 = create :user, created_at: Time.current - 2.9.days # Sanity check: too soon
    user_5 = create :user, created_at: Time.current - 4.1.days # Sanity check: too late

    User::Notification::Create.expects(:call).with(user_1, :onboarding_fundraising).once
    User::Notification::Create.expects(:call).with(user_2, :onboarding_fundraising).once
    User::Notification::Create.expects(:call).with(user_3, :onboarding_fundraising).once
    User::Notification::Create.expects(:call).with(user_4, :onboarding_fundraising).never
    User::Notification::Create.expects(:call).with(user_5, :onboarding_fundraising).never

    CreateOnboardingNotificationsJob.perform_now
  end
end
