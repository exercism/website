require "test_helper"

class TranslationRepoTest < ActiveSupport::TestCase
  test "nothing is checked out in test unless a test publishes something" do
    assert_nil TranslationRepo.version
    assert_nil TranslationRepo.frontend_catalog_url(:hu)
    assert_equal "hu", TranslationRepo.cache_key(:hu)
  end

  test "lives beside the other repositories on efs" do
    Exercism.config.stubs(efs_repositories_mount_point: "/mnt/efs/repos")

    assert_equal "/mnt/efs/repos/i18n", TranslationRepo.root.to_s
  end

  test "paths match exercism/i18n's layout" do
    Exercism.config.stubs(efs_repositories_mount_point: "/mnt/efs/repos")

    assert_equal "/mnt/efs/repos/i18n/locales/hu/website/backend.json", TranslationRepo.backend_catalog_path(:hu).to_s
    assert_equal "/mnt/efs/repos/i18n/locales/hu/website/frontend.json", TranslationRepo.frontend_catalog_path(:hu).to_s
    assert_equal "/mnt/efs/repos/i18n/locales/hu/content/ab/cd/ef0123456789abcdef0123456789abcdef01.md",
      TranslationRepo.content_path(:hu, "abcdef0123456789abcdef0123456789abcdef01", ".md").to_s
    assert_raises(ArgumentError) { TranslationRepo.content_path(:hu, "../../etc/passwd", ".md") }
  end

  test "the version is the checkout's head, through a loose ref, packed refs or a detached head" do
    with_published_translations({}) do
      sha = commit_translations!
      assert_equal sha, TranslationRepo.version

      git = TranslationRepo.root / ".git"
      packed = "abcdef0123456789abcdef0123456789abcdef01"
      File.write(git / "packed-refs", "# pack-refs with: peeled fully-peeled sorted\n#{packed} refs/heads/main\n")
      File.delete(git / "refs/heads/main")
      TranslationRepo.expire!
      assert_equal packed, TranslationRepo.version

      File.write(git / "HEAD", "0123456789abcdef0123456789abcdef01234567\n")
      TranslationRepo.expire!
      assert_equal "0123456789abcdef0123456789abcdef01234567", TranslationRepo.version

      File.write(git / "HEAD", "ref: refs/heads/gone\n")
      TranslationRepo.expire!
      assert_nil TranslationRepo.version
    end
  end

  test "the version is only re-read after the check interval" do
    with_published_translations({}) do
      first = TranslationRepo.version
      File.write(TranslationRepo.root / ".git/refs/heads/main", "0123456789abcdef0123456789abcdef01234567\n")

      assert_equal first, TranslationRepo.version

      travel_monotonic(TranslationRepo::CHECK_INTERVAL_SECONDS + 1) do
        assert_equal "0123456789abcdef0123456789abcdef01234567", TranslationRepo.version
      end
    end
  end

  test "the cache key is the locale and its own tree sha, and english needs neither" do
    with_git_translations_checkout do
      write_git_translation!("locales/hu/website/backend.json", { greeting: "Szia" }.to_json)

      key = TranslationRepo.cache_key(:hu)

      assert_match(/\Ahu-[0-9a-f]{40}\z/, key)
      assert_equal "en", TranslationRepo.cache_key(:en)
      I18n.with_locale(:hu) { assert_equal key, TranslationRepo.cache_key }
      I18n.with_locale(:en) { assert_equal "en", TranslationRepo.cache_key }
    end
  end

  test "the cache key changes for any file under the locale, including a content blob keeping its name" do
    with_git_translations_checkout do
      write_git_translation!("locales/hu/website/backend.json", { greeting: "Szia" }.to_json)
      write_git_translation!("locales/hu/content/ab/cd/ef0123456789abcdef0123456789abcdef01.md", "Első")

      key = TranslationRepo.cache_key(:hu)

      write_git_translation!("locales/hu/content/ab/cd/ef0123456789abcdef0123456789abcdef01.md", "Javított")
      corrected = TranslationRepo.cache_key(:hu)

      refute_equal key, corrected

      write_git_translation!("locales/hu/website/backend.json", { greeting: "Helló" }.to_json)

      refute_equal corrected, TranslationRepo.cache_key(:hu)
    end
  end

  test "the cache key does not change when a commit touches nothing under the locale" do
    with_git_translations_checkout do
      write_git_translation!("locales/hu/website/backend.json", { greeting: "Szia" }.to_json)

      key = TranslationRepo.cache_key(:hu)
      version = TranslationRepo.version

      write_git_translation!("locales/sl/website/backend.json", { greeting: "Zdravo" }.to_json)

      refute_equal version, TranslationRepo.version
      assert_equal key, TranslationRepo.cache_key(:hu)
    end
  end

  test "a locale with no directory in the checkout falls back to the version" do
    with_git_translations_checkout do
      write_git_translation!("locales/hu/website/backend.json", { greeting: "Szia" }.to_json)

      assert_equal "sl-#{TranslationRepo.version}", TranslationRepo.cache_key(:sl)
    end
  end

  test "a checkout whose tree shas cannot be read falls back to the version" do
    with_published_translations(hu: { backend: { greeting: "Szia" } }) do
      assert_equal "hu-#{TranslationRepo.version}", TranslationRepo.cache_key(:hu)

      previous = TranslationRepo.version
      commit_translations!

      refute_equal previous, TranslationRepo.version
      assert_equal "hu-#{TranslationRepo.version}", TranslationRepo.cache_key(:hu)
      assert_equal "en", TranslationRepo.cache_key(:en)
    end
  end

  test "the locale's tree sha is read once per version" do
    with_git_translations_checkout do
      write_git_translation!("locales/hu/website/backend.json", { greeting: "Szia" }.to_json)

      key = TranslationRepo.cache_key(:hu)

      Open3.expects(:capture2e).never

      assert_equal key, TranslationRepo.cache_key(:hu)
    end
  end

  test "the frontend catalog url carries a digest of the file, memoised per version" do
    with_published_translations(hu: { frontend: { ns: { a: "b" } } }) do
      hash = TranslationRepo.catalog_hash({ ns: { a: "b" } }.to_json)
      assert_equal "/i18n/hu/frontend-#{hash}.json", TranslationRepo.frontend_catalog_url(:hu)
      assert_nil TranslationRepo.frontend_catalog_url(:nl)

      File.write(TranslationRepo.frontend_catalog_path(:hu), { ns: { a: "c" } }.to_json)
      assert_equal hash, TranslationRepo.frontend_catalog_hash(:hu)

      commit_translations!
      assert_equal TranslationRepo.catalog_hash({ ns: { a: "c" } }.to_json), TranslationRepo.frontend_catalog_hash(:hu)
    end
  end
end
