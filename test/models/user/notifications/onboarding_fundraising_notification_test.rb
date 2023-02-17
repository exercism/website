require 'test_helper'

class User::Notifications::OnboardingFundraisingNotificationTest < ActiveSupport::TestCase
  test "keys are valid" do
    user = create :user

    notification = User::Notifications::OnboardingFundraisingNotification.create!(user:)

    assert_equal "#{user.id}|onboarding_fundraising|", notification.uniqueness_key
    assert_equal "Support our goal: Give everyone an equal chance to learn and master programming. Check the donate section for more info!", notification.text # rubocop:disable Layout/LineLength
    assert_equal :icon, notification.image_type
    assert notification.image_url.starts_with?('/assets/icons/donate-')
    assert_equal "https://test.exercism.org/donate", notification.url
    assert_equal "/donate", notification.path
  end
end
