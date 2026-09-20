require "test_helper"

class LanguageSwitcherTest < ActionDispatch::IntegrationTest
  test "the signed-out header links to the current page in every served locale" do
    get "/tracks"

    assert_response :ok
    assert_select ".c-language-switcher a[href='/hu/tracks'][hreflang=hu][data-locale-pref=hu]"
    assert_select ".c-language-switcher a[href='/tracks'][hreflang=en][data-locale-pref=en]"
  end

  test "each option carries the endonym and the english name" do
    get "/tracks"

    assert_select ".c-language-switcher a[hreflang=hu] .native", text: "magyar"
    assert_select ".c-language-switcher a[hreflang=hu] .english", text: "Hungarian"
  end

  test "the links follow the page" do
    get "/hu/tracks"

    assert_select ".c-language-switcher a[href='/tracks'][hreflang=en]"
  end

  test "the signed-in header has no switcher" do
    sign_in!

    get "/tracks"

    assert_response :ok
    assert_select ".c-language-switcher", 0
  end
end
