require "test_helper"

class LocaleFrontendCatalogTest < ActionDispatch::IntegrationTest
  test "english pages name their locale and need no catalog" do
    get "/tracks"

    assert_select "meta[name='exercism-locale'][content=en]"
    assert_select "meta[name='exercism-i18n-catalog']", count: 0
    assert_select "link[rel=preload][as=fetch]", count: 0
  end

  test "a localised page renders and preloads the exact immutable catalog url" do
    with_served_locales(:hu) do
      with_published_translations(hu: { frontend: { "components/tracks": { title: "Nyelvek" } } }) do
        LocaleRoster.stubs(production: %i[en hu])
        hash = TranslationStore.current_hash(:hu, :frontend)
        url = "/i18n/website/hu/frontend-#{hash}.json"

        get "/hu/tracks"
        assert_select "meta[name='exercism-locale'][content=hu]"
        assert_select "meta[name='exercism-i18n-catalog'][content='#{url}']"
        assert_select "link[rel=preload][as=fetch][crossorigin=anonymous][href='#{url}']"

        get "/tracks"
        assert_select "meta[name='exercism-i18n-catalog']", count: 0

        get url
        assert_response :ok
        assert_equal({ "components/tracks" => { "title" => "Nyelvek" } }, response.parsed_body)

        get "/i18n/website/hu/frontend-0123456789ab.json"
        assert_response :not_found
      end
    end
  end

  test "the catalog url is on the assets host" do
    with_published_translations(hu: { frontend: {} }) do
      Rails.application.config.stubs(asset_host: "https://assets.exercism.org")
      hash = TranslationStore.current_hash(:hu, :frontend)

      assert_equal "https://assets.exercism.org/i18n/website/hu/frontend-#{hash}.json", TranslationStore.frontend_catalog_url(:hu)
      assert_nil TranslationStore.frontend_catalog_url(:en)
    end
  end
end
