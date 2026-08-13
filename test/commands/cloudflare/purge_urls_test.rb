require 'test_helper'

class Cloudflare::PurgeUrlsTest < ActiveSupport::TestCase
  test "posts urls to cloudflare" do
    with_cloudflare_secrets do
      stub = stub_request(:post, "https://api.cloudflare.com/client/v4/zones/zone-123/purge_cache").
        with(
          body: { files: ["https://exercism.org/foo", "https://exercism.org/bar"] }.to_json,
          headers: { 'Authorization' => "Bearer token-123" }
        ).
        to_return(status: 200, body: { success: true }.to_json)

      Cloudflare::PurgeUrls.(["https://exercism.org/foo", "https://exercism.org/bar"])

      assert_requested stub
    end
  end

  test "batches at 100 urls per request" do
    with_cloudflare_secrets do
      urls = Array.new(250) { |idx| "https://exercism.org/#{idx}" }

      stub = stub_request(:post, "https://api.cloudflare.com/client/v4/zones/zone-123/purge_cache").
        to_return(status: 200, body: { success: true }.to_json)

      Cloudflare::PurgeUrls.(urls)

      assert_requested stub, times: 3
    end
  end

  test "deduplicates and compacts urls" do
    with_cloudflare_secrets do
      stub = stub_request(:post, "https://api.cloudflare.com/client/v4/zones/zone-123/purge_cache").
        with(body: { files: ["https://exercism.org/foo"] }.to_json).
        to_return(status: 200, body: { success: true }.to_json)

      Cloudflare::PurgeUrls.(["https://exercism.org/foo", "https://exercism.org/foo", nil])

      assert_requested stub
    end
  end

  test "does nothing without urls" do
    with_cloudflare_secrets do
      Cloudflare::PurgeUrls.([])
    end
  end

  test "does nothing without credentials" do
    with_purging_enabled do
      Exercism.secrets.cloudflare_zone_id = ""
      Exercism.secrets.cloudflare_api_token = ""

      Cloudflare::PurgeUrls.(["https://exercism.org/foo"])
    end
  end

  test "does nothing outside production" do
    Exercism.secrets.cloudflare_zone_id = "zone-123"
    Exercism.secrets.cloudflare_api_token = "token-123"

    # Deliberately not stubbing the environment: secrets carry fake values
    # outside production, so this asserts we do not act on them.
    Cloudflare::PurgeUrls.(["https://exercism.org/foo"])
  ensure
    Exercism.secrets.delete_field(:cloudflare_zone_id)
    Exercism.secrets.delete_field(:cloudflare_api_token)
  end

  private
  def with_cloudflare_secrets(&)
    with_purging_enabled do
      Exercism.secrets.cloudflare_zone_id = "zone-123"
      Exercism.secrets.cloudflare_api_token = "token-123"
      yield
    end
  end

  def with_purging_enabled
    Rails.env.stubs(:test?).returns(false)
    Rails.env.stubs(:development?).returns(false)
    yield
  ensure
    Exercism.secrets.delete_field(:cloudflare_zone_id) if Exercism.secrets.respond_to?(:cloudflare_zone_id)
    Exercism.secrets.delete_field(:cloudflare_api_token) if Exercism.secrets.respond_to?(:cloudflare_api_token)
  end
end
