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

  test "the track page takes its title and description through the catalogs" do
    track = create :track, slug: "ruby", title: "Ruby"

    get "/tracks/ruby"
    assert_meta_tags "Ruby on Exercism",
      "Get fluent in Ruby by solving #{track.reload.num_exercises} exercises. And then level up with mentoring from our world-class team." # rubocop:disable Layout/LineLength

    with_hu_meta_tags(track: { title: "%<track_title>s az Exercismen", description: "%<num_exercises>s feladat %<track_title>s nyelven." }) do # rubocop:disable Layout/LineLength
      get "/hu/tracks/ruby"
      assert_meta_tags "Ruby az Exercismen", "0 feladat Ruby nyelven."
    end
  end

  test "the exercise page takes its title and description through the catalogs" do
    exercise = create :practice_exercise, title: "Bob"

    get track_exercise_url(exercise.track, exercise)
    assert_meta_tags "Bob in Ruby on Exercism",
      "Can you solve Bob in Ruby? Improve your Ruby skills with support from our world-class team of mentors."

    with_hu_meta_tags(exercise: { title: "%<exercise_title>s a(z) %<track_title>s nyelven", description: "Megoldod a(z) %<exercise_title>s feladatot?" }) do # rubocop:disable Layout/LineLength
      get track_exercise_url(exercise.track, exercise, locale: :hu)
      assert_meta_tags "Bob a(z) Ruby nyelven", "Megoldod a(z) Bob feladatot?"
    end
  end

  test "the concept page takes its title and description through the catalogs" do
    concept = create :concept, :with_git_data, name: "Strings"
    track = concept.track
    num_exercises = UserTrack::External.new(track).num_exercises_for_concept(concept)

    get track_concept_url(track, concept)
    assert_meta_tags "Strings in #{track.title} on Exercism",
      "Master Strings in #{track.title} by solving #{num_exercises} exercises, with support from our world-class team."

    with_hu_meta_tags(concept: { title: "%<concept_name>s fogalom", description: "%<num_exercises>s feladat a(z) %<concept_name>s fogalomhoz." }) do # rubocop:disable Layout/LineLength
      get track_concept_url(track, concept, locale: :hu)
      assert_meta_tags "Strings fogalom", "#{num_exercises} feladat a(z) Strings fogalomhoz."
    end
  end

  test "the default description is taken through the catalogs" do
    get "/tracks"
    assert_meta_tags "Exercism", "Learn, practice and get world-class mentoring in over 50 languages. 100% free."
    with_hu_meta_tags(default_description: "Tanulj és kapj világszínvonalú mentorálást.") do
      get "/hu/tracks"
      assert_meta_tags "Exercism", "Tanulj és kapj világszínvonalú mentorálást."
    end
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

  private
  def with_hu_meta_tags(tree, &) = with_published_translations(hu: { backend: { helpers: { meta_tags: tree } } }, &)

  def assert_meta_tags(title, description)
    assert_select "title", text: title
    assert_select "meta[name=description][content=?]", description
    assert_select "meta[name='twitter:title'][content=?]", title
    assert_select "meta[name='twitter:description'][content=?]", description
    assert_select "meta[property='og:title'][content=?]", title
    assert_select "meta[property='og:description'][content=?]", description
  end
end
