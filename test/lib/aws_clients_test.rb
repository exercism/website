require "test_helper"

class AwsClientsTest < ActiveSupport::TestCase
  test "s3_client is memoized per process" do
    assert_same Exercism.s3_client, Exercism.s3_client
  end

  test "s3_client keeps idle connections alive for 60 seconds" do
    assert_equal 60, Exercism.s3_client.config.http_idle_timeout
  end

  test "s3_client retains path style addressing" do
    assert Exercism.s3_client.config.force_path_style
  end
end
