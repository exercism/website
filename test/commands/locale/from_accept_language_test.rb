require "test_helper"

class Locale::FromAcceptLanguageTest < ActiveSupport::TestCase
  test "no header means no locale" do
    assert_nil Locale::FromAcceptLanguage.(nil, %i[en hu])
    assert_nil Locale::FromAcceptLanguage.("", %i[en hu])
  end

  test "first supported language in preference order" do
    assert_equal :hu, Locale::FromAcceptLanguage.("hu-HU,hu;q=0.9,en;q=0.8", %i[en hu])
    assert_equal :en, Locale::FromAcceptLanguage.("en-US,en;q=0.9,hu;q=0.8", %i[en hu])
    assert_equal :hu, Locale::FromAcceptLanguage.("de-DE,de;q=0.9,hu;q=0.5,en;q=0.4", %i[en hu])
  end

  test "q values beat header order" do
    assert_equal :hu, Locale::FromAcceptLanguage.("en;q=0.5, hu;q=0.9", %i[en hu])
  end

  test "q=0, wildcards and junk are ignored" do
    assert_equal :en, Locale::FromAcceptLanguage.("hu;q=0, *;q=0.5, en;q=0.1", %i[en hu])
    assert_nil Locale::FromAcceptLanguage.("*", %i[en hu])
    assert_nil Locale::FromAcceptLanguage.(";;,,q=", %i[en hu])
  end

  test "nothing supported is nil, not english" do
    assert_nil Locale::FromAcceptLanguage.("de-DE,de;q=0.9", %i[en hu])
  end

  test "regional variants resolve through the variant table" do
    assert_equal :"es-419", Locale::FromAcceptLanguage.("es-CL,es;q=0.9", %i[en es-419 es-ES])
  end
end
