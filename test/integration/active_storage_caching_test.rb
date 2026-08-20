require 'test_helper'

class ActiveStorageCachingTest < ActionDispatch::IntegrationTest
  test "attachments route to the proxy endpoint, not the redirect endpoint" do
    partner = create :partner
    attach_logo(partner)

    url = Rails.application.routes.url_helpers.url_for(partner.light_logo)

    assert_includes url, "/rails/active_storage/blobs/proxy/"
  end

  test "proxied attachments are publicly cacheable at the edge" do
    partner = create :partner
    attach_logo(partner)

    get Rails.application.routes.url_helpers.url_for(partner.light_logo)

    assert_response :success
    assert_includes response.headers["Cache-Control"], "public"
    refute_includes response.headers["Cache-Control"].to_s, "private"
    assert_nil response.headers["Set-Cookie"]
  end

  private
  def attach_logo(partner)
    partner.light_logo.attach(
      io: File.open(Rails.root.join("test", "fixtures", "test.jpg")),
      filename: "test.jpg",
      content_type: "image/jpeg"
    )
  end
end
