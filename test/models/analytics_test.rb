require "test_helper"

class AnalyticsTest < ActiveSupport::TestCase
  # The client is only built in production, so nothing else in the test
  # suite would notice if the gem weren't loaded.
  test "the PostHog gem is loaded" do
    client = PostHog::Client.new(api_key: "phc_test", host: Analytics::HOST, test_mode: true)

    assert_instance_of PostHog::Client, client
  end
end
