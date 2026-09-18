require_relative './base_test_case'

class API::BaseControllerLocaleTest < API::BaseTestCase
  HUNGARIAN = "Magyar értesítés".freeze
  CATALOG = { notifications: { mentor_started_discussion: { "1": HUNGARIAN } } }.freeze

  test "the locale of the page that made the request is used" do
    assert_hungarian(header: "hu")
  end

  test "a regional tag is normalised before it is used" do
    assert_hungarian(header: "hu-HU")
  end

  test "the user's own locale is used when the request carries none" do
    assert_hungarian(user_locale: "hu")
  end

  test "the page's locale beats the user's own" do
    assert_english(header: "en", user_locale: "hu")
  end

  test "a page locale the user may not view is ignored" do
    assert_english(header: "hu", production: false)
  end

  test "a user locale the user may not view is ignored" do
    assert_english(user_locale: "hu", production: false)
  end

  test "a translator may view their own work in progress locale" do
    assert_hungarian(header: "hu", production: false, translator: true)
  end

  test "a locale this environment does not serve is ignored" do
    assert_english(header: "de", production: false)
  end

  test "responses vary on the locale header" do
    setup_user
    get api_notifications_path, headers: @headers, as: :json

    assert_response :ok
    assert_includes response.headers["Vary"].split(", "), "X-Exercism-Locale"
  end

  test "the publicly cached identity endpoint does not vary on it" do
    get api_public_user_path(create(:user).handle), as: :json

    assert_response :ok
    refute_includes response.headers["Vary"].to_s.split(", "), "X-Exercism-Locale"
  end

  private
  def assert_hungarian(**) = assert_equal HUNGARIAN, notification_text(**)

  def assert_english(**)
    actual = notification_text(**)
    assert_equal @english, actual
  end

  def notification_text(header: nil, user_locale: nil, production: true, translator: false)
    with_hungarian(production:) do
      setup_user
      @current_user.update!(locale: user_locale) if user_locale
      @current_user.update!(translator_locales: ["hu"]) if translator
      @english = create_notification.text

      headers = header ? @headers.merge('X-Exercism-Locale' => header) : @headers
      get api_notifications_path, headers:, as: :json
      assert_response :ok

      return response.parsed_body["results"].first["text"]
    end
  end

  def create_notification
    create :mentor_started_discussion_notification,
      user: @current_user,
      status: :unread,
      params: { discussion: create(:mentor_discussion) }
  end

  def with_hungarian(production:, &)
    Dir.mktmpdir do |dir|
      TranslationRepo.stubs(root: Pathname.new(dir) / "i18n")
      with_served_locales(:hu) do
        LocaleRoster.stubs(production: %i[en hu]) if production
        with_published_translations(hu: { backend: CATALOG }, &)
      end
    end
  end
end
