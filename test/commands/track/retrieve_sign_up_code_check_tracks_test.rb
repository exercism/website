require "test_helper"

class Track::RetrieveSignUpCodeCheckTracksTest < ActiveSupport::TestCase
  test "only returns active tracks with a sign-up snippet" do
    go = create :track, slug: "go", title: "Go"
    ruby = create :track, slug: "ruby", title: "Ruby"
    elm = create :track, slug: "elm", title: "Elm", active: false
    cache_snippets(go => "package main", ruby => "", elm => "main = text")

    assert_equal [go], Track::RetrieveSignUpCodeCheckTracks.()
  end

  test "puts the three most popular tracks first, then the rest alphabetically" do
    tracks = {
      "zig" => 10, "awk" => 20, "go" => 500, "python" => 900, "ruby" => 300, "elm" => 400
    }.map { |slug, num_students| create :track, slug:, title: slug.titleize, num_students: }
    cache_snippets(tracks.index_with { |track| "#{track.slug} code" })

    assert_equal %w[python go elm awk ruby zig], Track::RetrieveSignUpCodeCheckTracks.().map(&:slug)
  end

  test "reads cached snippets without going to git" do
    go = create :track, slug: "go"
    cache_snippets(go => "package main")

    Track.any_instance.expects(:sign_up_snippet).never

    assert_equal [go], Track::RetrieveSignUpCodeCheckTracks.()
  end

  test "reads uncached snippets from git and caches them for the endpoint" do
    go = create :track, slug: "go"
    Track.any_instance.expects(:sign_up_snippet).once.returns("package main")

    assert_equal [go], Track::RetrieveSignUpCodeCheckTracks.()
    assert_equal "package main", Track::RetrieveSignUpSnippet.(go)
  end

  private
  def cache_snippets(snippets)
    snippets.each do |track, snippet|
      Rails.cache.write(Track::RetrieveSignUpSnippet.cache_key(track), snippet)
    end
  end
end
