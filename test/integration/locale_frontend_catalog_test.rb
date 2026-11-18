require "test_helper"

class LocaleFrontendCatalogTest < ActionDispatch::IntegrationTest
  test "english pages name their locale and need no catalog" do
    get "/tracks"

    assert_select "meta[name='exercism-locale'][content=en]"
    assert_select "meta[name='exercism-i18n-catalog']", count: 0
    assert_select "link[rel=preload][as=fetch]", count: 0
  end

  test "a localised page renders and preloads the exact immutable catalog url" do
    with_published_translations(hu: { frontend: { "components/tracks": { title: "Nyelvek" } } }) do
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
      assert_redirected_to url

      assert_raises(ActionController::RoutingError) { get "/i18n/nl/frontend-0123456789ab.json" }
    end
  end

  test "an old catalog version is served from its stored copy, or redirects to the current one" do
    setup_s3_cache_bucket!

    with_published_translations(hu: { frontend: { ns: { a: "b-#{SecureRandom.hex}" } } }) do
      old_url = TranslationRepo.frontend_catalog_url(:hu)
      old_hash = TranslationRepo.frontend_catalog_hash(:hu)
      old_json = File.binread(TranslationRepo.frontend_catalog_path(:hu))
      File.write(TranslationRepo.frontend_catalog_path(:hu), { ns: { a: "c" } }.to_json)

      get old_url
      assert_response :found
      assert_redirected_to "/i18n/hu/frontend-#{TranslationRepo.catalog_hash({ ns: { a: "c" } }.to_json)}.json"

      upload_to_s3(Exercism.config.aws_cache_bucket, "i18n/frontend/hu/#{old_hash}.json", old_json)
      get old_url
      assert_response :ok
      assert_equal old_json, response.body

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
