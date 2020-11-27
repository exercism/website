require "test_helper"
require "hcaptcha"

class HCaptchaTest < ActiveSupport::TestCase
  test "verification succeeds if success status is true" do
    RestClient.unstub(:post)
    HCaptcha.endpoint = "https://hcaptcha.com"
    stub_request(:post, "https://hcaptcha.com/siteverify").
      to_return(body: { success: true }.to_json)

    assert HCaptcha.verify("token").succeeded?

    RestClient.stubs(:post)
  end

  test "verification fails if success status is false" do
    RestClient.unstub(:post)
    HCaptcha.endpoint = "https://hcaptcha.com"
    stub_request(:post, "https://hcaptcha.com/siteverify").
      to_return(body: { success: false }.to_json)

    assert HCaptcha.verify("token").failed?

    RestClient.stubs(:post)
  end

  test "verification fails if status code is not 200" do
    RestClient.unstub(:post)
    HCaptcha.endpoint = "https://hcaptcha.com"
    stub_request(:post, "https://hcaptcha.com/siteverify").
      to_return(status: 500)

    assert HCaptcha.verify("token").failed?

    RestClient.stubs(:post)
  end
end
