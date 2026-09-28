require "test_helper"

class SitemapsControllerTest < ActionDispatch::IntegrationTest
  test "robots.txt disallows the auth pages in every locale" do
    get "/robots.txt"

    assert_response :ok
    assert_equal "text/plain", response.media_type
    assert_includes response.body, "User-agent: *\n"
    assert_includes response.body, "Disallow: /users/\n"
    assert_includes response.body, "Disallow: /*/users/\n"
    assert_includes response.body, "Allow: /\n"
    assert_match %r{^Sitemap: https?://.+/sitemap\.xml$}, response.body
  end
end
