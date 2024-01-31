require "test_helper"

class User::InvalidateAvatarInCloudfrontTest < ActiveSupport::TestCase
  test "calls out to invalidate" do
    user = create :user, version: 3

    Infrastructure::InvalidateCloudfrontItems.expects(:call).with(
      :assets, [
        "/avatars/#{user.id}/0",
        "/avatars/#{user.id}/1",
        "/avatars/#{user.id}/2",
        "/avatars/#{user.id}/3"
      ]
    )

    User::InvalidateAvatarInCloudfront.(user)
  end
end
