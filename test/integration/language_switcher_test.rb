require "test_helper"

class LanguageSwitcherTest < ActionDispatch::IntegrationTest
  test "the switcher sits with the auth buttons and links to the current page in every served locale" do
    get "/tracks"

    assert_response :ok
    assert_select ".auth-buttons .c-language-switcher a[href='/hu/tracks'][hreflang=hu][data-locale-pref=hu]"
    assert_select ".auth-buttons .c-language-switcher a[href='/tracks'][hreflang=en][data-locale-pref=en]"
  end

  test "each option carries a flag, the endonym and the english name" do
    get "/tracks"

    assert_select ".c-language-switcher a[hreflang=hu] img.flag[alt='']"
    assert_select ".c-language-switcher a[hreflang=hu] .native", text: "magyar"
    assert_select ".c-language-switcher a[hreflang=hu] .english", text: "Hungarian"
  end

  test "the toggle shows the current locale's flag" do
    get "/hu/tracks"

    assert_select ".c-language-switcher > .toggle img.flag[alt='']"
    assert_select ".c-language-switcher > .toggle", text: ""
  end

  test "languages we do not serve yet are listed as coming soon" do
    get "/tracks"

    assert_select ".c-language-switcher .option[class~='--disabled'] .native", text: "français"
    assert_select ".c-language-switcher .option[class~='--disabled'] .badge"
    assert_select ".c-language-switcher a[hreflang=fr]", 0
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
