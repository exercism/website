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
        url = TranslationRepo.frontend_catalog_url(:hu)
        assert_match %r{\A/i18n/hu/frontend-[0-9a-f]{12}\.json\z}, url

        get "/hu/tracks"
        assert_select "meta[name='exercism-locale'][content=hu]"
        assert_select "meta[name='exercism-i18n-catalog'][content='#{url}']"
        assert_select "link[rel=preload][as=fetch][crossorigin=anonymous][href='#{url}']"

        get "/tracks"
        assert_select "meta[name='exercism-i18n-catalog']", count: 0

        get url
        assert_response :ok
        assert_equal "max-age=31536000, public, immutable", response.headers["Cache-Control"]
        assert_equal({ "components/tracks" => { "title" => "Nyelvek" } }, response.parsed_body)

        get "/i18n/hu/frontend-0123456789ab.json"
        assert_response :not_found

        assert_raises(ActionController::RoutingError) { get "/i18n/nl/frontend-0123456789ab.json" }
      end
    end
  end

  test "a catalog is never served under a stale hash" do
    with_published_translations(hu: { frontend: { ns: { a: "b" } } }) do
      url = TranslationRepo.frontend_catalog_url(:hu)
      File.write(TranslationRepo.frontend_catalog_path(:hu), { ns: { a: "c" } }.to_json)

      get url
      assert_response :not_found

      commit_translations!
      get TranslationRepo.frontend_catalog_url(:hu)
      assert_response :ok
      assert_equal({ "ns" => { "a" => "c" } }, response.parsed_body)
    end
  end

  test "no catalog without a checkout" do
    get "/i18n/hu/frontend-0123456789ab.json"
    assert_response :not_found
  end
end
