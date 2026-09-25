require "test_helper"

class Locale::LanguagesTest < ActiveSupport::TestCase
  test "live holds the served locales, led by the one being read" do
    codes = Locale::Languages.(:hu)[:live].map(&:code)

    assert_equal %w[hu en], codes.first(2)
    assert_equal LocaleConfig::SERVED.map(&:to_s).sort, codes.sort
  end

  test "english leads when it is not the locale being read" do
    languages = Locale::Languages.(:en)

    assert_equal %w[en], languages[:live].map(&:code).first(1)
  end

  test "coming soon holds everything we name and do not serve" do
    languages = Locale::Languages.(:en)

    codes = languages[:coming_soon].map(&:code)
    assert_includes codes, "de"
    LocaleConfig::SERVED.each { |locale| refute_includes codes, locale.to_s }
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
