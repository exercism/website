require "test_helper"

class Locale::AlternatesTest < ActiveSupport::TestCase
  test "nothing to declare while english is the only served locale" do
    with_available_locales { assert_empty Locale::Alternates.("https://exercism.org/tracks") }
  end

  test "one url per served locale plus x-default" do
    expected = {
      "x-default" => "https://exercism.org/tracks/ruby",
      "en" => "https://exercism.org/tracks/ruby",
      "hu" => "https://exercism.org/hu/tracks/ruby"
    }
    assert_equal expected, Locale::Alternates.("https://exercism.org/tracks/ruby")
  end

  test "the map is the same whichever variant it is built from" do
    assert_equal Locale::Alternates.("https://exercism.org/tracks"), Locale::Alternates.("https://exercism.org/hu/tracks")
    assert_equal Locale::Alternates.("https://exercism.org/"), Locale::Alternates.("https://exercism.org/hu")
  end

  test "es-419 is declared in the form search engines accept, but keeps its url" do
    with_available_locales(:'es-419', :'es-ES') do
      alternates = Locale::Alternates.("https://exercism.org/tracks")
      assert_equal "https://exercism.org/es-419/tracks", alternates["es"]
      assert_equal "https://exercism.org/es-ES/tracks", alternates["es-ES"]
      refute_includes alternates.keys, "es-419"
    end
  end

  test "keeps the query string" do
    assert_equal "https://exercism.org/hu/tracks?page=2", Locale::Alternates.("https://exercism.org/tracks?page=2")["hu"]
  end
end
