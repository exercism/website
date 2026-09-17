require "test_helper"

class Cache::GenerateEtagTest < ActiveSupport::TestCase
  test "differs per locale" do
    english = Cache::GenerateEtag.(["page"], nil)

    with_published_translations(hu: { backend: { a: "b" } }) do
      assert_equal english, Cache::GenerateEtag.(["page"], nil)
      I18n.with_locale(:hu) { refute_equal english, Cache::GenerateEtag.(["page"], nil) }
    end
  end

  test "a published translation fix changes it, for backend and frontend alike" do
    with_published_translations(hu: { backend: { a: "b" }, frontend: { ns: { a: "b" } } }) do
      I18n.with_locale(:hu) do
        before = Cache::GenerateEtag.(["page"], nil)
        assert_equal before, Cache::GenerateEtag.(["page"], nil)

        publish_translation_catalog!(:hu, :backend, { a: "fixed" })
        after_backend = Cache::GenerateEtag.(["page"], nil)
        refute_equal before, after_backend

        publish_translation_catalog!(:hu, :frontend, { ns: { a: "fixed" } })
        refute_equal after_backend, Cache::GenerateEtag.(["page"], nil)
      end
    end
  end
end
