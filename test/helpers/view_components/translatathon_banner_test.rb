require "test_helper"

class ViewComponents::TranslatathonBannerTest < ActiveSupport::TestCase
  # Before the event ends, so the banner is live.
  BEFORE_END = Time.utc(2026, 8, 1)

  def resolve(header, now: BEFORE_END)
    ViewComponents::TranslatathonBanner.(header, now:)
  end

  test "returns nil for English speakers (catalog language)" do
    assert_nil resolve("en-US,en;q=0.9")
  end

  test "returns nil for a blank header" do
    assert_nil resolve("")
    assert_nil resolve(nil)
  end

  test "returns nil once the event is over" do
    assert_nil resolve("fr-FR", now: Time.utc(2026, 8, 4))
    assert_nil resolve("fr-FR", now: Time.utc(2026, 9, 1))
  end

  test "shows the program banner in the target language" do
    banner = resolve("fr-FR,fr;q=0.9,en;q=0.8")

    assert_equal "Vous voulez nous aider à traduire Exercism en français ? ", banner.pre
    assert_equal "Rejoignez la session de traduction", banner.link
    assert_equal "https://i18n.jiki.io", banner.url
    assert_equal "ltr", banner.dir
  end

  test "sets rtl for right-to-left program languages" do
    assert_equal "rtl", resolve("ar").dir
    assert_equal "rtl", resolve("fa-IR").dir
    assert_equal "rtl", resolve("ur").dir
  end

  test "picks the first non-catalog language, skipping English" do
    banner = resolve("en-GB,en;q=0.9,de;q=0.8")

    assert_equal "Möchtest du uns helfen, Exercism ins Deutsche zu übersetzen? ", banner.pre
  end

  test "orders by q-value, not header order" do
    # de has the higher quality despite appearing after fr.
    banner = resolve("fr;q=0.5,de;q=0.9")

    assert_equal "Mach bei der Übersetzungssession mit", banner.link
  end

  test "falls back to English copy with the language name for non-program languages" do
    banner = resolve("sv-SE,sv;q=0.9")

    assert_equal "Want to help us translate Exercism to Swedish? ", banner.pre
    assert_equal "Join the Translatathon", banner.link
    assert_equal "ltr", banner.dir
  end

  test "returns nil when the first non-catalog language has no name" do
    assert_nil resolve("xx-YY")
  end

  test "maps Spanish variants to es-ES and es-419" do
    assert_equal "es-ES", program_locale("es-ES", "es")
    assert_equal "es-419", program_locale("es-MX", "es")
    assert_equal "es-419", program_locale("es", "es")
  end

  test "maps Portuguese variants to pt-pt and pt-BR" do
    assert_equal "pt-pt", program_locale("pt-PT", "pt")
    assert_equal "pt-BR", program_locale("pt-BR", "pt")
    assert_equal "pt-BR", program_locale("pt", "pt")
  end

  test "maps Chinese variants to zh-TW and zh-CN" do
    assert_equal "zh-TW", program_locale("zh-TW", "zh")
    assert_equal "zh-TW", program_locale("zh-HK", "zh")
    assert_equal "zh-TW", program_locale("zh-Hant", "zh")
    assert_equal "zh-CN", program_locale("zh-CN", "zh")
    assert_equal "zh-CN", program_locale("zh", "zh")
  end

  private
  def program_locale(tag, base)
    ViewComponents::TranslatathonBanner.new("").send(:program_locale, tag, base)
  end
end
