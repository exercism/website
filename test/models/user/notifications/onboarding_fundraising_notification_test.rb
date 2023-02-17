require 'test_helper'

class User::Notifications::OnboardingFundraisingNotificationTest < ActiveSupport::TestCase
  test "keys are valid" do
    user = create :user

    notification = User::Notifications::OnboardingFundraisingNotification.create!(user:)

    assert_equal "#{user.id}|onboarding_fundraising|", notification.uniqueness_key
    assert_equal I18n.t('notifications.onboarding_fundraising')[1].strip, notification.text
    assert_equal :icon, notification.image_type
    assert notification.image_url.starts_with?('/assets/icons/donate-')
    assert_equal "https://test.exercism.org/donate", notification.url
    assert_equal "/donate", notification.path
  end
end
