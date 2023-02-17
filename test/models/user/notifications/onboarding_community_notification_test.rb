require 'test_helper'

class User::Notifications::OnboardingCommunityNotificationTest < ActiveSupport::TestCase
  test "keys are valid" do
    user = create :user

    notification = User::Notifications::OnboardingCommunityNotification.create!(user:)

    assert_equal "#{user.id}|onboarding_community|", notification.uniqueness_key
    assert_equal "Community is at the heart of Exercism. Try our forums and mentoring, get involved on YouTube and Twitch. Check the community section for more info!", notification.text # rubocop:disable Layout/LineLength
    assert_equal :icon, notification.image_type
    assert notification.image_url.starts_with?('/assets/icons/community-')
    assert_equal "https://test.exercism.org/community", notification.url
    assert_equal "/community", notification.path
  end
end
