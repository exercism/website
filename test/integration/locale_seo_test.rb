require "test_helper"

class LocaleSeoTest < ActionDispatch::IntegrationTest
  test "every served locale is self-canonical with reciprocal hreflang" do
    ["/tracks", "/hu/tracks"].each do |path|
      get path

      assert_select "link[rel=canonical][href='http://test.exercism.org#{path}']"
      assert_select "link[rel=alternate][hreflang=x-default][href='http://test.exercism.org/tracks']"
      assert_select "link[rel=alternate][hreflang=en][href='http://test.exercism.org/tracks']"
      assert_select "link[rel=alternate][hreflang=hu][href='http://test.exercism.org/hu/tracks']"
      assert_select "meta[name=robots]", count: 0
      assert_nil response.headers["X-Robots-Tag"]
    end

    assert_select "html[lang=hu][dir=ltr]"
  end

  test "the query string is left out of the canonical url" do
    get "/tracks?criteria=ruby"

    assert_select "html[lang='en-US'][dir='ltr']"
    assert_select "link[rel=canonical][href='http://test.exercism.org/tracks']"
  end

  test "an explicit canonical is localised and drives the alternates" do
    track = create :track, slug: "ruby"

    get "/hu/tracks/ruby"

    assert_select "link[rel=canonical][href='http://test.exercism.org/hu/tracks/#{track.slug}']"
    assert_select "link[rel=alternate][hreflang=en][href='http://test.exercism.org/tracks/ruby']"
  end

  test "a naked page rendered in the user's locale is canonical at its prefixed url" do
    track = create :track, slug: "ruby"

    user = create :user
    user.update!(locale: "hu")
    sign_in!(user)

    get "/tracks"
    assert_select "link[rel=canonical][href='http://test.exercism.org/hu/tracks']"
    assert_select "link[rel=alternate][hreflang=en][href='http://test.exercism.org/tracks']"

    get "/tracks/ruby"
    assert_select "link[rel=canonical][href='http://test.exercism.org/hu/tracks/#{track.slug}']"
  end

  test "rtl locales declare their direction" do
    assert_equal "rtl", Locale::Direction.(:ar)
    assert_equal "rtl", Locale::Direction.("fa-IR")
    assert_equal "ltr", Locale::Direction.(:hu)
  end

  test "the sitemap lists every served locale with the same alternates as the page head" do
    create :track, slug: "ruby"
    create :blog_post

    get "/sitemap-general.xml"

    xml = Nokogiri::XML(response.body)
    xml.remove_namespaces!
    locs = xml.xpath("//url/loc").map(&:text)
    assert_includes locs, "http://test.exercism.org/tracks"
    assert_includes locs, "http://test.exercism.org/hu/tracks"

    hu = xml.xpath("//url[loc='http://test.exercism.org/hu/tracks']/link").to_h { |l| [l["hreflang"], l["href"]] }
    assert_equal Locale::Alternates.("http://test.exercism.org/tracks"), hu
  end
end
