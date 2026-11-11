require "test_helper"

class JikiTest < ActiveSupport::TestCase
  test "the default locale is unprefixed" do
    assert_equal "https://jiki.io?utm_source=exercism&utm_medium=nav", Jiki.url(:en, medium: "nav")
  end

  test "every other locale is prefixed" do
    assert_equal "https://jiki.io/hu?utm_source=exercism&utm_medium=nav", Jiki.url(:hu, medium: "nav")
  end

  test "the current locale is used by default" do
    assert_equal "https://jiki.io?utm_source=exercism&utm_medium=nav", Jiki.url(medium: "nav")
    I18n.with_locale(:hu) do
      assert_equal "https://jiki.io/hu?utm_source=exercism&utm_medium=nav", Jiki.url(medium: "nav")
    end
  end

  test "a path goes after the locale segment" do
    assert_equal "https://jiki.io/auth/signup?utm_source=exercism&utm_medium=footer",
      Jiki.url(:en, path: "/auth/signup", medium: "footer")
    assert_equal "https://jiki.io/hu/auth/signup?utm_source=exercism&utm_medium=footer",
      Jiki.url(:hu, path: "auth/signup", medium: "footer")
  end

  test "content is added after the medium" do
    assert_equal "https://jiki.io/auth/signup?utm_source=exercism&utm_medium=sign_up&utm_content=absolute_beginner",
      Jiki.url(:en, path: "auth/signup", medium: "sign_up", content: "absolute_beginner")
  end

  test "a medium is required" do
    assert_raises(ArgumentError) { Jiki.url(:en) }
  end
end
