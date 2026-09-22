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
end
