require "test_helper"

class TranslationStoreTest < ActiveSupport::TestCase
  test "nothing is published in test unless a test publishes it" do
    assert_nil TranslationStore.current_hash(:hu, :backend)
    assert_empty TranslationStore.pointers
  end

  test "paths match exercism/i18n's published layout" do
    TranslationStore.root = "/mnt/efs/i18n"

    assert_equal "/mnt/efs/i18n/website/hu/backend-0123456789ab.json",
      TranslationStore.catalog_path(:hu, :backend, "0123456789ab").to_s
    assert_equal "/mnt/efs/i18n/content/hu/ab/cd/ef0123456789abcdef0123456789abcdef01.md",
      TranslationStore.content_path(:hu, "abcdef0123456789abcdef0123456789abcdef01", ".md").to_s
    assert_raises(ArgumentError) { TranslationStore.content_path(:hu, "../../etc/passwd", ".md") }
  ensure
    TranslationStore.root = nil
  end

  test "reads the pointer, and ignores a malformed one" do
    with_published_translations(hu: { backend: { a: "b" }, frontend: { ns: { a: "b" } } }) do
      assert_match TranslationStore::HASH_FORMAT, TranslationStore.current_hash(:hu, :backend)
      assert_match TranslationStore::HASH_FORMAT, TranslationStore.current_hash("hu", "frontend")

      File.write(TranslationStore.root / "website/hu/frontend.current.json", { hash: "../../nope" }.to_json)
      TranslationStore.expire!
      assert_nil TranslationStore.current_hash(:hu, :frontend)

      File.write(TranslationStore.root / "website/hu/frontend.current.json", "{ half writ")
      TranslationStore.expire!
      assert_nil TranslationStore.current_hash(:hu, :frontend)
    end
  end

  test "pointers are only re-read after the check interval" do
    with_published_translations(hu: { backend: { a: "b" } }) do
      first = TranslationStore.current_hash(:hu, :backend)
      dir = TranslationStore.root / "website/hu"
      File.write(dir / "backend.current.json", { hash: "0123456789ab" }.to_json)

      assert_equal first, TranslationStore.current_hash(:hu, :backend)

      travel_monotonic(TranslationStore::CHECK_INTERVAL_SECONDS + 1) do
        assert_equal "0123456789ab", TranslationStore.current_hash(:hu, :backend)
      end
    end
  end
end
