require "test_helper"

class TranslationStore::BackendTest < ActiveSupport::TestCase
  test "is the I18n backend, with pluralization and fallbacks" do
    assert_instance_of TranslationStore::Backend, I18n.backend
    assert_includes I18n.backend.class.ancestors, I18n::Backend::Pluralization
    assert_includes I18n.backend.class.ancestors, I18n::Backend::Fallbacks
  end

  test "a published catalog is served, over rails-i18n, with english underneath" do
    catalog = {
      # rubocop:disable Style/FormatStringToken
      store_test: { greeting: "Szia %{name}", things: { one: "egy dolog", other: "%{count} dolog" } },
      # rubocop:enable Style/FormatStringToken
      date: { formats: { long: "%Y. %B %-d. (published)" } }
    }

    with_published_translations(hu: { backend: catalog }) do
      I18n.with_locale(:hu) do
        assert_equal "Szia iHiD", I18n.t("store_test.greeting", name: "iHiD")
        assert_equal "egy dolog", I18n.t("store_test.things", count: 1)
        assert_equal "5 dolog", I18n.t("store_test.things", count: 5)
        assert_equal "%Y. %B %-d. (published)", I18n.t("date.formats.long")
        assert_equal "január", I18n.t("date.month_names")[1] # still rails-i18n
        assert_kind_of String, I18n.t("devise.failure.invalid") # still english
      end
      assert_equal "gone", I18n.t("store_test.greeting", name: "x", default: "gone")
    end

    I18n.with_locale(:hu) { assert_equal "gone", I18n.t("store_test.greeting", name: "x", default: "gone") }
  end

  test "a new pointer swaps the whole catalog in, dropping keys that went away" do
    with_published_translations(hu: { backend: { store_test: { a: "egy", b: "kettő" } } }) do
      I18n.with_locale(:hu) do
        assert_equal "egy", I18n.t("store_test.a")

        publish_translation_catalog!(:hu, :backend, { store_test: { a: "EGY" } })
        assert_equal "EGY", I18n.t("store_test.a")
        assert_equal "gone", I18n.t("store_test.b", default: "gone")
      end
    end
  end

  test "a pointer change is only noticed after the check interval" do
    with_published_translations(hu: { backend: { store_test: { a: "egy" } } }) do
      I18n.with_locale(:hu) do
        assert_equal "egy", I18n.t("store_test.a")

        dir = TranslationStore.root / "website/hu"
        json = { hu: { store_test: { a: "EGY" } } }.to_json
        File.write(dir / "backend-0123456789ab.json", json)
        File.write(dir / "backend.current.json", { hash: "0123456789ab" }.to_json)
        assert_equal "egy", I18n.t("store_test.a")

        travel_monotonic(TranslationStore::CHECK_INTERVAL + 1) do
          assert_equal "EGY", I18n.t("store_test.a")
        end
      end
    end
  end

  test "a pointer to an artifact that isn't there keeps the current catalog, and says so once" do
    with_published_translations(hu: { backend: { store_test: { a: "egy" } } }) do
      I18n.with_locale(:hu) do
        assert_equal "egy", I18n.t("store_test.a")

        Sentry.expects(:capture_exception).once
        File.write(TranslationStore.root / "website/hu/backend.current.json", { hash: "0123456789ab" }.to_json)
        TranslationStore.expire!

        assert_equal "egy", I18n.t("store_test.a")
        assert_equal "egy", I18n.t("store_test.a")
      end
    end
  end

  test "an artifact for the wrong locale is refused" do
    Sentry.expects(:capture_exception).at_least_once
    with_published_translations(hu: { backend: {} }) do
      dir = TranslationStore.root / "website/hu"
      File.write(dir / "backend-0123456789ab.json", { nl: { store_test: { a: "een" } } }.to_json)
      File.write(dir / "backend.current.json", { hash: "0123456789ab" }.to_json)
      TranslationStore.expire!

      I18n.with_locale(:hu) { assert_equal "gone", I18n.t("store_test.a", default: "gone") }
    end
  end

  test "a production locale falling back to english is reported, once per key" do
    LocaleRoster.stubs(production: %i[en hu])

    with_published_translations(hu: { backend: { store_test: { a: "egy" } } }) do
      I18n.backend.store_translations(:en, store_test: { only_english: "Hello" })
      Sentry.expects(:capture_message).once.with do |message, **opts|
        message == "Missing hu translation: store_test.only_english" && opts[:tags] == { locale: "hu" }
      end

      I18n.with_locale(:hu) do
        assert_equal "Hello", I18n.t("store_test.only_english")
        assert_equal "Hello", I18n.t("store_test.only_english")
        assert_equal "egy", I18n.t("store_test.a")
      end
    end
  end

  test "a work in progress locale falls back quietly" do
    with_published_translations(hu: { backend: {} }) do
      I18n.backend.store_translations(:en, store_test: { only_english: "Hello" })
      Sentry.expects(:capture_message).never

      I18n.with_locale(:hu) { assert_equal "Hello", I18n.t("store_test.only_english") }
    end
  end

  test "works from a thread with no request, as sidekiq does" do
    with_published_translations(hu: { backend: { store_test: { a: "egy" } } }) do
      result = Thread.new { I18n.with_locale(:hu) { I18n.t("store_test.a") } }.value
      assert_equal "egy", result
    end
  end
end
