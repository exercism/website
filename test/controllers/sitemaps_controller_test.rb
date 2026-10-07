require "test_helper"

class SitemapsControllerTest < ActionDispatch::IntegrationTest
  test "robots.txt disallows the auth pages in every locale and the advert redirects" do
    get "/robots.txt"

    assert_response :ok
    assert_equal "text/plain", response.media_type
    assert_includes response.body, "User-agent: *\n"
    assert_includes response.body, "Disallow: /users/\n"
    assert_includes response.body, "Disallow: /*/users/\n"
    assert_includes response.body, "Disallow: /adverts/\n"
    assert_includes response.body, "Allow: /\n"
    assert_match %r{^Sitemap: https?://.+/sitemap\.xml$}, response.body
  end

  test "track sitemap lists each page once, by its English url" do
    track = create :track, slug: "ruby"

    with_available_locales(:hu) do
      get "/sitemap-tracks-#{track.slug}.xml"
    end

    assert_response :ok
    doc = Nokogiri::XML(response.body)
    doc.remove_namespaces!
    locs = doc.xpath("//url/loc").map(&:text)

    assert_equal locs.uniq, locs
    assert_includes locs, "http://test.exercism.org/tracks/ruby"
    refute(locs.any? { |loc| loc.include?("/hu/") })
    assert_empty doc.xpath("//link")
  end
end
