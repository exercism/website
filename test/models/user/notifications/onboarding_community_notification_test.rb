require 'test_helper'

class User::Notifications::OnboardingCommunityNotificationTest < ActiveSupport::TestCase
  test "keys are valid" do
    user = create :user

    notification = User::Notifications::OnboardingCommunityNotification.create!(user:)

    assert_equal "#{user.id}|onboarding_community|", notification.uniqueness_key
    assert_equal I18n.t('notifications.onboarding_community')[1].strip, notification.text
    assert_equal :icon, notification.image_type
    assert_match(%r{^/assets/icons/community-[a-z0-9]+\.svg$}, notification.image_url)
    assert_equal "https://test.exercism.org/community", notification.url
    assert_equal "/community", notification.path
  end
end
