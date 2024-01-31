require "test_helper"

class User::InvalidateCloudfrontItemsTest < ActiveSupport::TestCase
  test "calls out to invalidate for assets" do
    # Stub production mode for this test
    Rails.env.expects(:production?).returns(true)

    freeze_time do
      items = [mock, mock, mock]
      uuid = SecureRandom.uuid
      SecureRandom.expects(:uuid).returns(uuid)

      client = mock
      client.expects(:create_invalidation).with(
        distribution_id: Exercism.config.assets_cloudfront_distribution_id,
        invalidation_batch: {
          paths: { quantity: 3, items: },
          caller_reference: "website-invalidation-#{Time.current.to_i}-#{uuid}"
        }
      )
      Exercism.expects(cloudfront_client: client)

      Infrastructure::InvalidateCloudfrontItems.(:assets, items)
    end
  end

  test "calls out to invalidate for website" do
    # Stub production mode for this test
    Rails.env.expects(:production?).returns(true)

    freeze_time do
      items = [mock]
      uuid = SecureRandom.uuid
      SecureRandom.expects(:uuid).returns(uuid)

      client = mock
      client.expects(:create_invalidation).with(
        distribution_id: Exercism.config.website_cloudfront_distribution_id,
        invalidation_batch: {
          paths: { quantity: 1, items: },
          caller_reference: "website-invalidation-#{Time.current.to_i}-#{uuid}"
        }
      )
      Exercism.expects(cloudfront_client: client)

      Infrastructure::InvalidateCloudfrontItems.(:website, items)
    end
  end
end
