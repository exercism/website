require 'test_helper'

class User::Notifications::AddedToContributorsPageNotificationTest < ActiveSupport::TestCase
  include Propshaft::Helper

  test "keys are valid" do
    user = create :user

    notification = User::Notifications::AddedToContributorsPageNotification.create!(user:)
    assert_equal "#{user.id}|added_to_contributors_page|", notification.uniqueness_key
    assert_equal "You now appear on our Contributors page. Thank you for contributing to Exercism!", notification.text
    assert_equal :icon, notification.image_type
    assert notification.image_url.starts_with?('/assets/icons/contributors-')
    assert_equal Exercism::Routes.contributing_contributors_url, notification.url
    assert_equal "/contributing/contributors", notification.path
  end
end
