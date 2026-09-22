require "test_helper"

class Locale::LanguagesTest < ActiveSupport::TestCase
  test "live holds the served locales, led by the one being read" do
    languages = Locale::Languages.(:hu)

    assert_equal %w[hu en], languages[:live].map(&:code)
  end

  test "english leads when it is not the locale being read" do
    languages = Locale::Languages.(:en)

    assert_equal %w[en], languages[:live].map(&:code).first(1)
  end

  test "coming soon holds everything we name and do not serve" do
    languages = Locale::Languages.(:en)

    codes = languages[:coming_soon].map(&:code)
    assert_includes codes, "fr"
    refute_includes codes, "en"
    refute_includes codes, "hu"
    assert_equal Locale::Name::NAMES.keys.size - I18n.available_locales.size, codes.size
  end

  test "coming soon runs latin-script endonyms first, then the other scripts" do
    codes = Locale::Languages.(:en)[:coming_soon].map(&:code)

    assert_equal "català", Locale::Name.(codes.first).native
    assert_operator codes.index("ca"), :<, codes.index("ja")
  end

  test "every language carries a flag" do
    languages = Locale::Languages.(:en)

    (languages[:live] + languages[:coming_soon]).each do |language|
      assert_equal Locale::Languages::FLAGS.fetch(language.code), language.flag
      assert File.exist?(Rails.root.join("app/images/flags/3x2/#{language.flag}.svg"))
    end
  end

  test "the languages spoken too widely for one country use the world flag" do
    languages = Locale::Languages.(:en)[:coming_soon].index_by(&:code)

    assert_equal "world", languages["ar"].flag
    assert_equal "world", languages["es-419"].flag
  end
end
