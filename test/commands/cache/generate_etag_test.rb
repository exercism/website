require "test_helper"

class Cache::GenerateEtagTest < ActiveSupport::TestCase
  test "differs per locale" do
    english = Cache::GenerateEtag.(["page"], nil)

    with_published_translations(hu: { backend: { a: "b" } }) do
      assert_equal english, Cache::GenerateEtag.(["page"], nil)
      I18n.with_locale(:hu) { refute_equal english, Cache::GenerateEtag.(["page"], nil) }
    end
  end

  test "a published translation fix changes it, for catalogs and content alike" do
    with_git_translations_checkout do
      write_git_translation!("locales/hu/website/backend.json", { a: "b" }.to_json)
      write_git_translation!("locales/hu/website/frontend.json", { ns: { a: "b" } }.to_json)
      write_git_translation!("locales/hu/content/ab/cd/ef.md", "Első")

      I18n.with_locale(:hu) do
        before = Cache::GenerateEtag.(["page"], nil)
        assert_equal before, Cache::GenerateEtag.(["page"], nil)

        write_git_translation!("locales/hu/website/backend.json", { a: "fixed" }.to_json)
        after_backend = Cache::GenerateEtag.(["page"], nil)
        refute_equal before, after_backend

        write_git_translation!("locales/hu/website/frontend.json", { ns: { a: "fixed" } }.to_json)
        after_frontend = Cache::GenerateEtag.(["page"], nil)
        refute_equal after_backend, after_frontend

        write_git_translation!("locales/hu/content/ab/cd/ef.md", "Javított")
        refute_equal after_frontend, Cache::GenerateEtag.(["page"], nil)
      end
    end
  end

  test "a push that touches no file the locale reads leaves it alone" do
    with_git_translations_checkout do
      write_git_translation!("locales/hu/website/backend.json", { a: "b" }.to_json)

      I18n.with_locale(:hu) do
        before = Cache::GenerateEtag.(["page"], nil)
        version = TranslationRepo.version

        write_git_translation!("locales/sl/website/backend.json", { a: "b" }.to_json)

        refute_equal version, TranslationRepo.version
        assert_equal before, Cache::GenerateEtag.(["page"], nil)
      end
    end
  end
end
