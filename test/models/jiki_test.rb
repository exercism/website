require "test_helper"

class JikiTest < ActiveSupport::TestCase
  test "the default locale is unprefixed" do
    assert_equal "https://jiki.io", Jiki.url(:en)
  end

  test "every other locale is prefixed" do
    assert_equal "https://jiki.io/hu", Jiki.url(:hu)
  end

  test "the current locale is used by default" do
    assert_equal "https://jiki.io", Jiki.url
    I18n.with_locale(:hu) { assert_equal "https://jiki.io/hu", Jiki.url }
  end

  test "a query string survives the prefix" do
    assert_equal "https://jiki.io?utm_source=exercism", Jiki.url(:en, query: "utm_source=exercism")
    assert_equal "https://jiki.io/hu?utm_source=exercism", Jiki.url(:hu, query: "utm_source=exercism")
  end

  test "a path goes after the locale segment" do
    assert_equal "https://jiki.io/auth/signup", Jiki.url(:en, path: "/auth/signup")
    assert_equal "https://jiki.io/hu/auth/signup?utm_source=exercism",
      Jiki.url(:hu, path: "auth/signup", query: "utm_source=exercism")
  end

  test "a medium adds the utm params" do
    assert_equal "https://jiki.io?utm_source=exercism&utm_medium=nav", Jiki.url(:en, medium: "nav")
    assert_equal "https://jiki.io/hu/auth/signup?utm_source=exercism&utm_medium=footer",
      Jiki.url(:hu, path: "auth/signup", medium: "footer")
  end

  test "a medium keeps an existing query string" do
    assert_equal "https://jiki.io?foo=bar&utm_source=exercism&utm_medium=nav",
      Jiki.url(:en, query: "foo=bar", medium: "nav")
  end

  test "with_utm keeps the fragment" do
    assert_equal "https://jiki.io/learn?a=1&utm_source=exercism&utm_medium=nav#top",
      Jiki.with_utm("https://jiki.io/learn?a=1#top", :nav)
  end

  test "with_utm leaves existing utm params alone" do
    assert_equal "https://jiki.io?utm_source=exercism&utm_medium=sign_up",
      Jiki.with_utm("https://jiki.io?utm_source=exercism&utm_medium=sign_up", "nav")
  end

  test "with_utm works on subdomains" do
    assert_equal "https://i18n.jiki.io?utm_source=exercism&utm_medium=banner",
      Jiki.with_utm("https://i18n.jiki.io", "banner")
  end
end
