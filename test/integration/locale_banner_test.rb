require "test_helper"

class LocaleBannerTest < ActionDispatch::IntegrationTest
  test "the page ships copy for every served locale" do
    get "/tracks"

    assert_response :ok
    data = banner_data

    assert_equal %w[en hu], data.keys.sort
    assert_equal "English", data["en"]["name"]
    assert_equal "magyar", data["hu"]["name"]
    assert_equal "ltr", data["hu"]["dir"]
    assert_equal "This page is in English.", data["en"]["pre"]
    assert_equal "View it in English", data["en"]["link"]
    assert_equal "Dismiss", data["en"]["dismiss"]
    assert data["hu"].values_at("pre", "link", "dismiss").all?(&:present?)
  end

  test "each locale carries the current path under its own prefix" do
    get "/hu/tracks?page=2"

    data = banner_data

    assert_equal "/tracks?page=2", data["en"]["path"]
    assert_equal "/hu/tracks?page=2", data["hu"]["path"]
  end

  test "no banner is server-rendered" do
    get "/hu/tracks", headers: { "Accept-Language" => "en" }

    assert_response :ok
    refute_includes response.body, "c-locale-banner"
    refute_includes response.body, "data-locale-banner="
  end

  test "an anonymous public page stays cacheable" do
    get "/hu/tracks", headers: { "Accept-Language" => "en" }

    refute_equal "private, no-store", response.headers["Cache-Control"]
  end

  private
  def banner_data
    JSON.parse(css_select("meta[name='exercism-locale-banner']").first["content"])
  end
end
