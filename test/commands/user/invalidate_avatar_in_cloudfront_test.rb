require "test_helper"

class User::InvalidateAvatarInCloudfrontTest < ActiveSupport::TestCase
  test "calls out to invalidate" do
    freeze_time do
      user = create :user

      client = mock
      client.expects(:create_invalidation).with(
        distribution_id: Exercism.config.website_assets_cloudfront_distribution_id,
        invalidation_batch: {
          paths: {
            quantity: 1,
            items: ["avatars/#{user.id}"]
          },
          caller_reference: "avatar-invalidation-for-user-#{user.id}-#{Time.current.to_i}"
        }
      )
      Exercism.expects(cloudfront_client: client)

      User::InvalidateAvatarInCloudfront.(user)
    end
  end
end
