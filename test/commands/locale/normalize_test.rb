require "test_helper"

class Locale::NormalizeTest < ActiveSupport::TestCase
  test "exact and case-insensitive matches" do
    assert_equal :hu, Locale::Normalize.("hu", %i[en hu])
    assert_equal :hu, Locale::Normalize.("HU", %i[en hu])
    assert_equal :"pt-BR", Locale::Normalize.("pt-br", %i[en pt-BR])
    assert_equal :"pt-BR", Locale::Normalize.("pt_BR", %i[en pt-BR])
  end

  test "a region we don't distinguish falls back to the language" do
    assert_equal :hu, Locale::Normalize.("hu-HU", %i[en hu])
    assert_equal :en, Locale::Normalize.("en-GB", %i[en hu])
    assert_equal :es, Locale::Normalize.("es-419", %i[en es])
    assert_equal :es, Locale::Normalize.("es-CL", %i[en es])
  end

  test "blank, junk and unserved tags are nil" do
    assert_nil Locale::Normalize.(nil, %i[en hu])
    assert_nil Locale::Normalize.("", %i[en hu])
    assert_nil Locale::Normalize.("*", %i[en hu])
    assert_nil Locale::Normalize.("de-DE", %i[en hu])
    assert_nil Locale::Normalize.("hungarian", %i[en hu])
  end

  test "defaults to the served locales" do
    assert_nil Locale::Normalize.("hu")
    with_served_locales(:hu) { assert_equal :hu, Locale::Normalize.("hu") }
  end

  test "spanish variants do not collapse" do
    locales = %i[en es-419 es-ES]

    assert_equal :"es-419", Locale::Normalize.("es-419", locales) # Chromium
    assert_equal :"es-419", Locale::Normalize.("es-CL", locales)  # Firefox, Safari
    assert_equal :"es-419", Locale::Normalize.("es-AR", locales)
    assert_equal :"es-419", Locale::Normalize.("es-US", locales)
    assert_equal :"es-419", Locale::Normalize.("es", locales)
    assert_equal :"es-ES", Locale::Normalize.("es-ES", locales)
    assert_equal :"es-ES", Locale::Normalize.("es-es", locales)
  end

  test "a variant we don't ship is not swapped for its sibling" do
    assert_nil Locale::Normalize.("es-ES", %i[en es-419])
    assert_equal :"es-419", Locale::Normalize.("es-MX", %i[en es-419])
    assert_nil Locale::Normalize.("pt-PT", %i[en pt-BR])
  end

  test "portuguese variants" do
    locales = %i[en pt-BR pt-PT]

    assert_equal :"pt-BR", Locale::Normalize.("pt", locales)
    assert_equal :"pt-BR", Locale::Normalize.("pt-BR", locales)
    assert_equal :"pt-PT", Locale::Normalize.("pt-PT", locales)
    assert_equal :"pt-PT", Locale::Normalize.("pt-AO", locales)
  end

  test "chinese variants split by script, then region" do
    locales = %i[en zh-CN zh-TW]

    assert_equal :"zh-CN", Locale::Normalize.("zh", locales)
    assert_equal :"zh-CN", Locale::Normalize.("zh-CN", locales)
    assert_equal :"zh-CN", Locale::Normalize.("zh-SG", locales)
    assert_equal :"zh-TW", Locale::Normalize.("zh-TW", locales)
    assert_equal :"zh-TW", Locale::Normalize.("zh-HK", locales)
    assert_equal :"zh-TW", Locale::Normalize.("zh-MO", locales)
    assert_equal :"zh-TW", Locale::Normalize.("zh-Hant", locales)
    assert_equal :"zh-TW", Locale::Normalize.("zh-Hant-HK", locales)
    assert_equal :"zh-CN", Locale::Normalize.("zh-Hans-HK", locales)
  end
end
