require 'test_helper'

class User::Notifications::OnboardingInsidersNotificationTest < ActiveSupport::TestCase
  test "keys are valid" do
    user = create :user

    notification = User::Notifications::OnboardingInsidersNotification.create!(user:)

    assert_equal "#{user.id}|onboarding_insiders|", notification.uniqueness_key
    assert_equal I18n.t('notifications.onboarding_insiders')[1].strip, notification.text
    assert_equal :icon, notification.image_type
    assert_match(%r{^/assets/icons/donate-[a-z0-9]+\.svg$}, notification.image_url)
    assert_equal "https://test.exercism.org/donate", notification.url
    assert_equal "/donate", notification.path
  end
end
