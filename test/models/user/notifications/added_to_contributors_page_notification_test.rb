require 'test_helper'

class User::Notifications::AddedToContributorsPageNotificationTest < ActiveSupport::TestCase
  include ActionView::Helpers::AssetUrlHelper

  test "keys are valid" do
    user = create :user

    notification = User::Notifications::AddedToContributorsPageNotification.create!(user: user)
    assert_equal "#{user.id}|added_to_contributors_page|", notification.uniqueness_key
    assert_equal "You now appear on our Contributors page. Thank you for contributing to Exercism!", notification.text
    assert_equal :icon, notification.image_type
    assert_equal asset_pack_url(
      "media/images/icons/contributors.svg",
      host: Rails.application.config.action_controller.asset_host
    ), notification.image_url
    assert_equal Exercism::Routes.contributing_contributors_url, notification.url
    assert_equal "/contributing/contributors", notification.path
  end
end
