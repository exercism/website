require 'test_helper'

class User::NotifyJikiOfInsiderChangeTest < ActiveSupport::TestCase
  WEBHOOK_URL = "https://api.jiki.test/webhooks/exercism".freeze
  SECRET = "test-jiki-webhook-secret".freeze

  setup do
    @original_url = Exercism.secrets.jiki_webhook_url
    @original_secret = Exercism.secrets.jiki_webhook_secret
    Exercism.secrets.jiki_webhook_url = WEBHOOK_URL
    Exercism.secrets.jiki_webhook_secret = SECRET
  end

  teardown do
    Exercism.secrets.jiki_webhook_url = @original_url
    Exercism.secrets.jiki_webhook_secret = @original_secret
  end

  test "posts signed activation payload" do
    user = create(:user)
    freeze_time = Time.utc(2026, 6, 11, 14, 32, 0)

    expected_body = {
      event: "insider.activated",
      exercism_id: user.id,
      occurred_at: freeze_time.iso8601
    }.to_json

    expected_signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), SECRET, expected_body)}"

    RestClient.expects(:post).with(
      WEBHOOK_URL,
      expected_body,
      content_type: :json,
      'X-Exercism-Signature' => expected_signature,
      'X-Exercism-Event' => "insider.activated"
    ).returns(stub(code: 200))

    travel_to freeze_time do
      User::NotifyJikiOfInsiderChange.(user, :activated)
    end
  end

  test "posts signed deactivation payload" do
    user = create(:user)

    RestClient.expects(:post).with do |_url, _body, headers|
      headers['X-Exercism-Event'] == "insider.deactivated"
    end.returns(stub(code: 200))

    User::NotifyJikiOfInsiderChange.(user, :deactivated)
  end

  test "raises on unknown event" do
    user = create(:user)

    assert_raises(ArgumentError) do
      User::NotifyJikiOfInsiderChange.(user, :renewed)
    end
  end

  test "is a no-op when webhook url is not configured" do
    Exercism.secrets.jiki_webhook_url = nil
    user = create(:user)

    RestClient.expects(:post).never

    User::NotifyJikiOfInsiderChange.(user, :activated)
  end

  test "requeues with backoff on non-2xx response" do
    user = create(:user)

    RestClient.expects(:post).returns(stub(code: 500))
    User::NotifyJikiOfInsiderChange.expects(:defer).with(user, :activated, attempt: 2, wait: 1.minute)

    User::NotifyJikiOfInsiderChange.(user, :activated)
  end

  test "requeues with longer backoff on later attempts" do
    user = create(:user)

    RestClient.expects(:post).returns(stub(code: 500))
    User::NotifyJikiOfInsiderChange.expects(:defer).with(user, :activated, attempt: 4, wait: 30.minutes)

    User::NotifyJikiOfInsiderChange.(user, :activated, attempt: 3)
  end

  test "requeues on connection error" do
    user = create(:user)

    RestClient.expects(:post).raises(Errno::ECONNREFUSED)
    User::NotifyJikiOfInsiderChange.expects(:defer).with(user, :activated, attempt: 2, wait: 1.minute)

    User::NotifyJikiOfInsiderChange.(user, :activated)
  end

  test "stops retrying after final attempt" do
    user = create(:user)

    RestClient.expects(:post).returns(stub(code: 500))
    User::NotifyJikiOfInsiderChange.expects(:defer).never

    User::NotifyJikiOfInsiderChange.(user, :activated, attempt: 6)
  end
end
