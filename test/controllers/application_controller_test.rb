require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "rescues MimeNegotiation::InvalidType error" do
    get "/",
      headers: {
        accept: "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*;q=0.8,application/signed-exchange;v=b3"
      }

    assert_equal 400, response.status
  end

  test "visiting HTML page updates last_visited_on date" do
    user = create :user, last_visited_on: nil

    sign_in!(user)
    get dashboard_path

    assert_equal Time.zone.today, user.reload.last_visited_on
  end

  test "calling API does not update last_visited_on date" do
    user = create :user, last_visited_on: nil

    sign_in!(user)
    get api_tracks_path, headers: @headers, as: :json

    assert_nil user.last_visited_on
  end

  test "sets the request context from the Cloudflare visitor location headers" do
    get "/", headers: {
      "CF-IPCountry" => "jp",
      "CF-IPLatitude" => "35.6837",
      "CF-IPLongitude" => "139.6805"
    }

    assert_equal(
      { country_code: "JP", coordinates: [35.6837, 139.6805] },
      Exercism.request_context
    )
  end

  test "leaves the request context empty without the Cloudflare headers" do
    get "/"

    assert_equal({ country_code: nil, coordinates: nil }, Exercism.request_context)
  end

  %w[XX T1].each do |code|
    test "treats a #{code} country code as unknown" do
      get "/", headers: { "CF-IPCountry" => code }

      assert_nil Exercism.request_context[:country_code]
    end
  end

  test "ignores an incomplete pair of coordinate headers" do
    get "/", headers: { "CF-IPCountry" => "JP", "CF-IPLatitude" => "35.6837" }

    assert_nil Exercism.request_context[:coordinates]
  end

  test "preloads only the latin Poppins subsets for the default locale" do
    get "/"

    assert_includes response.headers["Link"], "poppins-v20-latin-regular-"
    assert_includes response.headers["Link"], "poppins-v20-latin-600-"
    refute_includes response.headers["Link"], "poppins-v20-latin-ext-"
  end

  test "preloads the latin-ext Poppins subsets for other locales" do
    get "/", params: { locale: "hu" }

    assert_includes response.headers["Link"], "poppins-v20-latin-ext-regular-"
    assert_includes response.headers["Link"], "poppins-v20-latin-ext-600-"
  end
end
