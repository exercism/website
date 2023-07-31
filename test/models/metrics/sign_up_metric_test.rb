require "test_helper"

class Metrics::SignUpTest < ActiveSupport::TestCase
  test "create metric" do
    freeze_time do
      user = create :user, id: 3
      occurred_at = Time.current - 5.seconds
      request_context = { remote_ip: '127.0.0.1' }

      metric = Metric::Create.(:sign_up, occurred_at, user:, request_context:)

      assert_instance_of Metrics::SignUpMetric, metric
      assert_equal occurred_at, metric.occurred_at
      assert_equal user, metric.user
      assert_equal 'US', metric.country_code
      assert_equal "SignUpMetric|3", metric.uniqueness_key
    end
  end

  test "does not set extra params" do
    freeze_time do
      metric = Metric::Create.(:sign_up, Time.current, user: create(:user))

      expected = {}
      assert_equal expected, metric.params
    end
  end

  test "uniqueness_key is unique per solution" do
    uniqueness_keys = Array.new(10) do
      user = create :user
      Metric::Create.(:sign_up, Time.current, user:)
    end

    assert_equal uniqueness_keys.uniq.size, uniqueness_keys.size
  end

  test "idempotent" do
    user = create :user

    assert_idempotent_command do
      Metric::Create.(:sign_up, Time.utc(2012, 7, 25), user:)
    end
  end
end
