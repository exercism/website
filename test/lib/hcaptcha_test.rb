require "test_helper"

class HCaptchaTest < ActiveSupport::TestCase
  setup do
    @__skip_stubbing_rest_client__ = true
  end

  test "verification succeeds if success status is true" do
    stub_request(:post, "https://challenges.cloudflare.com/turnstile/v0/siteverify").
      to_return(body: { success: true }.to_json)

    assert HCaptcha.verify("token").succeeded?
  end

  test "verification fails if success status is false" do
    stub_request(:post, "https://challenges.cloudflare.com/turnstile/v0/siteverify").
      to_return(body: { success: false }.to_json)

    assert HCaptcha.verify("token").failed?
  end

  test "verification fails if status code is not 200" do
    stub_request(:post, "https://challenges.cloudflare.com/turnstile/v0/siteverify").
      to_return(status: 500)

    assert HCaptcha.verify("token").failed?
  end
end
