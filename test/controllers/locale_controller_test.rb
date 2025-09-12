require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  QUERY_PARAM = LocaleSupport::QUERY_PARAM

  setup do
    @track = create(:track, slug: :ruby)
    @naked_path = track_path(:ruby)                  # /tracks/ruby
    @hu_path    = track_path(:ruby, locale: "hu")    # /hu/tracks/ruby
  end

  test "naked path renders with default locale" do
    skip
    get @naked_path
    assert_response :ok
  end

  test "does not redirect if locale already in path" do
    skip
    get @hu_path
    assert_response :ok
  end

  test "does not redirect if logged-in user prefers default locale" do
    skip
    user = create(:user, locale: I18n.default_locale)
    sign_in!(user)
    get @naked_path
    assert_response :ok
  end

  test "redirects to logged-in user's saved non-default locale" do
    skip
    user = create(:user, locale: :hu)
    sign_in!(user)
    get @naked_path
    assert_redirected_to "#{@hu_path}?#{QUERY_PARAM}=1"
  end

  test "loop-breaker param skips redirect even if locale would trigger" do
    skip
    user = create(:user, locale: :hu)
    sign_in!(user)
    get "#{@naked_path}?#{QUERY_PARAM}=1"
    assert_response :ok
  end

  test "does not redirect non-GET requests for logged-in user" do
    skip
    user = create(:user, locale: :hu)
    sign_in!(user)
    post "#{@hu_path}/join"

    # Should not include the locale loop-breaker param from our concern
    refute_includes response.location.to_s, "?#{QUERY_PARAM}="
  end

  test "does not redirect if already on a different non-default locale path than user preference" do
    skip
    user = create(:user, locale: :fr)
    sign_in!(user)
    track_path(:ruby, locale: "fr")
    get @hu_path
    assert_response :ok
  end

  test "redirect preserves path and query parameters" do
    skip
    user = create(:user, locale: :hu)
    sign_in!(user)

    get "#{@naked_path}?page=2"
    assert_redirected_to "#{@hu_path}?page=2&#{QUERY_PARAM}=1"
  end

  test "logged-in user with non-default locale does not redirect if already on matching locale path" do
    skip
    user = create(:user, locale: :hu)
    sign_in!(user)

    get @hu_path

    assert_response :ok
  end

  test "redirect responses have Cache-Control set to no-store" do
    skip
    user = create(:user, locale: :hu)
    sign_in!(user)
    get @naked_path

    assert_equal "no-store", response.headers["Cache-Control"]
  end

  test "redirect /en/... to /..." do
    skip
    get "/en/tracks/ruby"
    assert_redirected_to "/tracks/ruby", status: :moved_permanently
  end

  test "redirect /en to /" do
    skip
    get "/en"
    assert_redirected_to "/", status: :moved_permanently
  end
end
