require "test_helper"

class LocaleSeoTest < ActionDispatch::IntegrationTest
  test "english pages are self-canonical, with no hreflang while there is nothing to alternate with" do
    get "/tracks?criteria=ruby"

    assert_select "html[lang='en-US'][dir='ltr']"
    assert_select "link[rel=canonical][href='http://test.exercism.org/tracks']"
    assert_select "link[rel=alternate][hreflang]", count: 0
    assert_select "meta[name=robots]", count: 0
    assert_nil response.headers["X-Robots-Tag"]
  end

  test "a production locale is self-canonical with reciprocal hreflang" do
    with_served_locales(:hu) do
      LocaleRoster.stubs(production: %i[en hu])

      ["/tracks", "/hu/tracks"].each do |path|
        get path

        assert_select "link[rel=canonical][href='http://test.exercism.org#{path}']"
        assert_select "link[rel=alternate][hreflang=x-default][href='http://test.exercism.org/tracks']"
        assert_select "link[rel=alternate][hreflang=en][href='http://test.exercism.org/tracks']"
        assert_select "link[rel=alternate][hreflang=hu][href='http://test.exercism.org/hu/tracks']"
        assert_select "meta[name=robots]", count: 0
      end

      assert_select "html[lang=hu][dir=ltr]"
    end
  end

  test "a work in progress locale is noindex and has no hreflang" do
    with_served_locales(:hu) do
      sign_in!(create(:user, :staff))
      get "/hu/tracks"

      assert_response :ok
      assert_select "meta[name=robots][content=noindex]"
      assert_equal "noindex", response.headers["X-Robots-Tag"]
      assert_select "link[rel=alternate][hreflang]", count: 0

      get "/tracks"
      assert_select "link[rel=alternate][hreflang]", count: 0
    end
  end

  test "an explicit canonical is localised and drives the alternates" do
    track = create :track, slug: "ruby"

    with_served_locales(:hu) do
      LocaleRoster.stubs(production: %i[en hu])
      get "/hu/tracks/ruby"

      assert_select "link[rel=canonical][href='http://test.exercism.org/hu/tracks/#{track.slug}']"
      assert_select "link[rel=alternate][hreflang=en][href='http://test.exercism.org/tracks/ruby']"
    end
  end

  test "a naked page rendered in the user's locale is canonical at its prefixed url" do
    track = create :track, slug: "ruby"

    with_served_locales(:hu) do
      LocaleRoster.stubs(production: %i[en hu])
      user = create :user
      user.update!(locale: "hu")
      sign_in!(user)

      get "/tracks"
      assert_select "link[rel=canonical][href='http://test.exercism.org/hu/tracks']"
      assert_select "link[rel=alternate][hreflang=en][href='http://test.exercism.org/tracks']"

      get "/tracks/ruby"
      assert_select "link[rel=canonical][href='http://test.exercism.org/hu/tracks/#{track.slug}']"
    end
  end

  test "rtl locales declare their direction" do
    assert_equal "rtl", LocaleRoster.direction(:ar)
    assert_equal "rtl", LocaleRoster.direction("fa-IR")
    assert_equal "ltr", LocaleRoster.direction(:hu)
  end

  test "the sitemap lists every production locale with the same alternates as the page head" do
    create :track, slug: "ruby"
    create :blog_post

    get "/sitemap-general.xml"
    refute_includes response.body, "hreflang"
    assert_includes response.body, "<loc>http://test.exercism.org/tracks</loc>"

    LocaleRoster.stubs(production: %i[en hu])
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
