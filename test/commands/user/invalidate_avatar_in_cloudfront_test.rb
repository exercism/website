require "test_helper"

class User::InvalidateAvatarInCloudfrontTest < ActiveSupport::TestCase
  test "calls out to invalidate" do
    freeze_time do
      user = create :user, version: 3

      client = mock
      client.expects(:create_invalidation).with(
        distribution_id: Exercism.config.website_assets_cloudfront_distribution_id,
        invalidation_batch: {
          paths: {
            quantity: 4,
            items: [
              "avatars/#{user.id}/0",
              "avatars/#{user.id}/1",
              "avatars/#{user.id}/2",
              "avatars/#{user.id}/3"
            ]
          },
          caller_reference: "avatar-invalidation-for-user-#{user.id}-#{Time.current.to_i}"
        }
      )
      Exercism.expects(cloudfront_client: client)

      User::InvalidateAvatarInCloudfront.(user)
    end
  end
end
