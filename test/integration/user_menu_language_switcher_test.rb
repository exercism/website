require "test_helper"

class UserMenuLanguageSwitcherTest < ActionDispatch::IntegrationTest
  test "the user menu offers every served language" do
    sign_in!

    get "/tracks"

    assert_response :ok
    assert_equal LocaleConfig::SERVED.map(&:to_s).sort, menu_locales.sort
  end

  test "the trigger shows the language in use, and its row is marked current" do
    sign_in!(create(:user, locale: "hu"))

    get "/tracks"

    assert_equal "magyar", language_html.at_css(".language-current .language-native").text
    assert_equal "hu", current_option['lang']
  end

  # The endonym leads, so a speaker finds their own language without reading
  # English first.
  test "each row pairs a flag with the endonym and the english name" do
    sign_in!

    get "/tracks"

    row = option_for("hu")
    assert_match %r{flags/3x2/hu}, row.at_css("img.language-flag")['src']
    assert_equal "magyar", row.at_css(".language-native").text
    assert_equal "Hungarian", row.at_css(".language-english").text
  end

  test "only the language in use carries a checkmark" do
    sign_in!(create(:user, locale: "hu"))

    get "/tracks"

    assert option_for("hu").at_css("img.language-check")
    assert_nil option_for("en").at_css("img.language-check")
  end

  # The menu posts from whichever page it was opened on, so the switch has to
  # come back to that page rather than the site root.
  test "each row carries the page the menu was opened on" do
    sign_in!

    get "/tracks?page=2"

    assert_equal(["/tracks?page=2"] * LocaleConfig::SERVED.size,
      language_html.css("input[name=return_to]").map { |input| input['value'] })
  end

  # The switch re-resolves the whole document, so it cannot be a Turbo visit
  # that swaps the body under the old <html lang>.
  test "the rows post outside Turbo" do
    sign_in!

    get "/tracks"

    assert_equal LocaleConfig::SERVED.size, language_html.css("form[data-turbo=false]").count
  end

  test "the languages sit behind a closed disclosure" do
    sign_in!

    get "/tracks"

    details = language_html.at_css("details.language-switcher")
    assert details
    assert_nil details['open']
  end

  # A setting rather than a destination, so it sits below every link, Sign out
  # included, separated from them by the divider.
  test "the switcher is the last row in the menu" do
    sign_in!

    get "/tracks"

    assert_equal "language", menu_items.last['className']
    assert_equal "opt", menu_items[-2]['className']
    assert_match(/Sign out/, menu_items[-2]['html'])
  end

  test "the menu has no switcher when only one language is served" do
    sign_in!

    with_available_locales(:en) do
      get "/tracks"
    end

    assert_nil language_item
  end

  private
  def menu_items
    node = Nokogiri::HTML(response.body).at_css("[data-react-id='dropdowns-dropdown']")
    JSON.parse(node['data-react-data'])['menu_items']
  end

  def language_item = menu_items.find { |item| item['className'] == 'language' }

  def language_html = Nokogiri::HTML.fragment(language_item.fetch('html'))

  def menu_locales = language_html.css("input[name=new_locale]").map { |input| input['value'] }
  def current_option = language_html.at_css(".language-option[aria-current=true] .language-native")

  def option_for(code)
    language_html.css(".language-panel li").find do |li|
      li.at_css("input[name=new_locale]")&.[]('value') == code
    end
  end
end
