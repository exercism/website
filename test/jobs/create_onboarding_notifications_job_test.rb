require "test_helper"

class CreateOnboardingNotificationsJobTest < ActiveJob::TestCase
  test "sends onboarding product notification to correct users" do
    user_1 = create :user, created_at: Time.current - 1.1.days
    user_2 = create :user, created_at: Time.current - 1.5.days
    user_3 = create :user, created_at: Time.current - 1.9.days

    user_4 = create :user, created_at: Time.current - 0.1.days # Sanity check: too soon
    user_5 = create :user, created_at: Time.current - 2.1.days # Sanity check: too late

    User::Notification::CreateEmailOnly.expects(:call).with(user_1, :onboarding_product).once
    User::Notification::CreateEmailOnly.expects(:call).with(user_2, :onboarding_product).once
    User::Notification::CreateEmailOnly.expects(:call).with(user_3, :onboarding_product).once
    User::Notification::CreateEmailOnly.expects(:call).with(user_4, :onboarding_product).never
    User::Notification::CreateEmailOnly.expects(:call).with(user_5, :onboarding_product).never

    CreateOnboardingNotificationsJob.perform_now
  end

  test "sends onboarding community notification to correct users" do
    user_1 = create :user, created_at: Time.current - 3.1.days
    user_2 = create :user, created_at: Time.current - 3.5.days
    user_3 = create :user, created_at: Time.current - 3.9.days

    user_4 = create :user, created_at: Time.current - 2.1.days # Sanity check: too soon
    user_5 = create :user, created_at: Time.current - 4.1.days # Sanity check: too late

    User::Notification::Create.expects(:call).with(user_1, :onboarding_community).once
    User::Notification::Create.expects(:call).with(user_2, :onboarding_community).once
    User::Notification::Create.expects(:call).with(user_3, :onboarding_community).once
    User::Notification::Create.expects(:call).with(user_4, :onboarding_community).never
    User::Notification::Create.expects(:call).with(user_5, :onboarding_community).never

    CreateOnboardingNotificationsJob.perform_now
  end

  test "sends onboarding insiders notification to correct users" do
    user_1 = create :user, created_at: Time.current - 5.1.days
    user_2 = create :user, created_at: Time.current - 5.5.days
    user_3 = create :user, created_at: Time.current - 5.9.days

    user_4 = create :user, created_at: Time.current - 4.9.days # Sanity check: too soon
    user_5 = create :user, created_at: Time.current - 6.1.days # Sanity check: too late

    User::Notification::Create.expects(:call).with(user_1, :onboarding_insiders).once
    User::Notification::Create.expects(:call).with(user_2, :onboarding_insiders).once
    User::Notification::Create.expects(:call).with(user_3, :onboarding_insiders).once
    User::Notification::Create.expects(:call).with(user_4, :onboarding_insiders).never
    User::Notification::Create.expects(:call).with(user_5, :onboarding_insiders).never

    CreateOnboardingNotificationsJob.perform_now
  end

  test "gracefully handle errors" do
    product_user_1 = create :user, created_at: Time.current - 1.5.days
    product_user_2 = create :user, created_at: Time.current - 1.6.days
    product_user_3 = create :user, created_at: Time.current - 1.7.days

    community_user_1 = create :user, created_at: Time.current - 3.5.days
    community_user_2 = create :user, created_at: Time.current - 3.6.days
    community_user_3 = create :user, created_at: Time.current - 3.7.days

    insider_user_1 = create :user, created_at: Time.current - 5.1.days
    insider_user_2 = create :user, created_at: Time.current - 5.3.days
    insider_user_3 = create :user, created_at: Time.current - 5.5.days

    User::Notification::CreateEmailOnly.expects(:call).with(product_user_1, :onboarding_product).raises
    User::Notification::CreateEmailOnly.expects(:call).with(product_user_2, :onboarding_product).once
    User::Notification::CreateEmailOnly.expects(:call).with(product_user_3, :onboarding_product).once

    User::Notification::Create.expects(:call).with(community_user_1, :onboarding_community).raises
    User::Notification::Create.expects(:call).with(community_user_2, :onboarding_community).once
    User::Notification::Create.expects(:call).with(community_user_3, :onboarding_community).once

    User::Notification::Create.expects(:call).with(insider_user_1, :onboarding_insiders).once
    User::Notification::Create.expects(:call).with(insider_user_2, :onboarding_insiders).raises
    User::Notification::Create.expects(:call).with(insider_user_3, :onboarding_insiders).once

    CreateOnboardingNotificationsJob.perform_now
  end

  test "creates onboarding product notification successfully" do
    user = create :user, created_at: Time.current - 1.1.days
    refute User::Notifications::OnboardingProductNotification.exists? # Sanity

    CreateOnboardingNotificationsJob.perform_now

    noti = User::Notifications::OnboardingProductNotification.last
    assert_equal user, noti.user
    assert_equal :email_only, noti.status
  end

  test "creates onboarding community notification successfully" do
    user = create :user, created_at: Time.current - 3.1.days
    refute User::Notifications::OnboardingCommunityNotification.exists? # Sanity

    CreateOnboardingNotificationsJob.perform_now

    noti = User::Notifications::OnboardingCommunityNotification.last
    assert_equal user, noti.user
    assert_equal :pending, noti.status
  end

  test "creates onboarding insiders notification successfully" do
    user = create :user, created_at: Time.current - 5.1.days
    refute User::Notifications::OnboardingInsidersNotification.exists? # Sanity

    CreateOnboardingNotificationsJob.perform_now

    noti = User::Notifications::OnboardingInsidersNotification.last
    assert_equal user, noti.user
    assert_equal :pending, noti.status
  end
end
