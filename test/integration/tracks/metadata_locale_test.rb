require "test_helper"

class Tracks::MetadataLocaleTest < ActionDispatch::IntegrationTest
  REPO_NAME = "track".freeze

  CATALOG = {
    "track:blurb" => "Egy dinamikus, nyílt forráskódú programozási nyelv.",
    "key_feature:fun:title" => "Fejlesztői boldogság",
    "key_feature:fun:content" => "A Ruby a boldogságot tartja szem előtt.",
    "exercise:bob:name" => "Bob magyarul",
    "exercise:bob:blurb" => "Bob egy lusta tinédzser."
  }.freeze

  setup do
    @track = create :track
    @exercise = create :practice_exercise,
      track: @track, slug: "bob", title: "Bob", blurb: "Bob is a lackadaisical teenager."
  end

  test "the track page renders the translated blurb, key features and exercise copy" do
    with_published_translations({}) do
      publish_translated_metadata!(:hu, REPO_NAME, CATALOG)

      get "/hu/tracks/ruby"

      assert_response :success
      assert_includes response.body, "Fejlesztői boldogság"
      assert_includes response.body, "Bob magyarul"
      assert_includes response.body, "Bob egy lusta tinédzser."
      refute_includes response.body, "Bob is a lackadaisical teenager."
    end
  end

  test "the exercises page renders the translated exercise copy" do
    with_published_translations({}) do
      publish_translated_metadata!(:hu, REPO_NAME, CATALOG)

      get "/hu/tracks/ruby/exercises"

      assert_response :success
      assert_includes response.body, "Bob magyarul"
      assert_includes response.body, "Bob egy lusta tinédzser."
      refute_includes response.body, "Bob is a lackadaisical teenager."
    end
  end

  test "the english pages are untouched" do
    with_published_translations({}) do
      publish_translated_metadata!(:hu, REPO_NAME, CATALOG)

      get "/tracks/ruby"
      assert_includes response.body, "Developer happiness"
      assert_includes response.body, "Bob is a lackadaisical teenager."
      refute_includes response.body, "Bob magyarul"

      get "/tracks/ruby/exercises"
      assert_includes response.body, "Bob is a lackadaisical teenager."
      refute_includes response.body, "Bob magyarul"
    end
  end
end
