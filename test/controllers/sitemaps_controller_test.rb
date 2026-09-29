require "test_helper"

class SitemapsControllerTest < ActionDispatch::IntegrationTest
  test "robots.txt disallows the auth pages in every locale" do
    get "/robots.txt"

    assert_response :ok
    assert_equal "text/plain", response.media_type
    assert_includes response.body, "User-agent: *\n"
    assert_includes response.body, "Disallow: /users/\n"
    assert_includes response.body, "Disallow: /*/users/\n"
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

  test "sitemap index lists the general, profiles and track sitemaps" do
    track = create :track, slug: "ruby"

    get "/sitemap.xml"

    assert_response :ok
    doc = Nokogiri::XML(response.body, &:strict)
    doc.remove_namespaces!

    assert_equal [
      "http://test.exercism.org/sitemap-general.xml",
      "http://test.exercism.org/sitemap-profiles.xml",
      "http://test.exercism.org/sitemap-tracks-#{track.slug}.xml"
    ], doc.xpath("//sitemapindex/sitemap/loc").map(&:text)
  end

  test "track sitemap is well-formed and describes each page" do
    track = create :track, slug: "ruby"

    get "/sitemap-tracks-#{track.slug}.xml"

    assert_response :ok
    doc = Nokogiri::XML(response.body, &:strict)
    assert_equal "http://www.sitemaps.org/schemas/sitemap/0.9", doc.root.namespace.href
    doc.remove_namespaces!

    url = doc.xpath("//urlset/url").find { |node| node.at_xpath("loc").text == "http://test.exercism.org/tracks/ruby" }
    assert_equal track.updated_at.xmlschema, url.at_xpath("lastmod").text
    assert_equal "monthly", url.at_xpath("changefreq").text
    assert_equal "0.9", url.at_xpath("priority").text
  end
end
