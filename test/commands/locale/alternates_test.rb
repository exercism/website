require "test_helper"

class Locale::AlternatesTest < ActiveSupport::TestCase
  test "nothing to declare while english is the only production locale" do
    assert_empty Locale::Alternates.("https://exercism.org/tracks")
  end

  test "one url per production locale plus x-default" do
    LocaleRoster.stubs(production: %i[en hu])

    expected = {
      "x-default" => "https://exercism.org/tracks/ruby",
      "en" => "https://exercism.org/tracks/ruby",
      "hu" => "https://exercism.org/hu/tracks/ruby"
    }
    assert_equal expected, Locale::Alternates.("https://exercism.org/tracks/ruby")
  end

  test "the map is the same whichever variant it is built from" do
    LocaleRoster.stubs(production: %i[en hu], known: %i[en hu])

    assert_equal Locale::Alternates.("https://exercism.org/tracks"), Locale::Alternates.("https://exercism.org/hu/tracks")
    assert_equal Locale::Alternates.("https://exercism.org/"), Locale::Alternates.("https://exercism.org/hu")
  end

  test "work in progress locales are left out" do
    LocaleRoster.stubs(production: %i[en hu], known: %i[en hu nl])

    refute_includes Locale::Alternates.("https://exercism.org/tracks").keys, "nl"
  end

  test "es-419 is declared in the form search engines accept, but keeps its url" do
    LocaleRoster.stubs(production: %i[en es-419 es-ES], known: %i[en es-419 es-ES])

    alternates = Locale::Alternates.("https://exercism.org/tracks")
    assert_equal "https://exercism.org/es-419/tracks", alternates["es"]
    assert_equal "https://exercism.org/es-ES/tracks", alternates["es-ES"]
    refute_includes alternates.keys, "es-419"
  end

  test "keeps the query string" do
    LocaleRoster.stubs(production: %i[en hu])

    assert_equal "https://exercism.org/hu/tracks?page=2", Locale::Alternates.("https://exercism.org/tracks?page=2")["hu"]
  end
end
