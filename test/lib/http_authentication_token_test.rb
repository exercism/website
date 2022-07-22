require "test_helper"
require "hcaptcha"

class HttpAuthenticationTokenTest < ActiveSupport::TestCase
  test "returns token when using token auth" do
    header = 'Token token=f8a4f759-1131-44df-b453-6829027da8bb'
    token = HttpAuthenticationToken.from_header(header)
    assert_equal 'f8a4f759-1131-44df-b453-6829027da8bb', token
  end

  test "returns token when using token auth with multiple header values" do
    header = 'Token nonce=abc,token=f8a4f759-1131-44df-b453-6829027da8bb'
    token = HttpAuthenticationToken.from_header(header)
    assert_equal 'f8a4f759-1131-44df-b453-6829027da8bb', token
  end

  test "returns nil when using basic auth" do
    header = 'Basic ZnJlZDpmcmVk'
    token = HttpAuthenticationToken.from_header(header)
    assert_nil token
  end

  test "returns nil when using bearer auth" do
    header = 'Bearer ZnJlZDpmcmVk'
    token = HttpAuthenticationToken.from_header(header)
    assert_nil token
  end
end
