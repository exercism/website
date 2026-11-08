require "test_helper"

class Track::RetrieveSignUpSnippetTest < ActiveSupport::TestCase
  test "returns the track's sign-up snippet" do
    track = create :track
    track.stubs(:sign_up_snippet).returns("puts 'hi'")

    assert_equal "puts 'hi'", Track::RetrieveSignUpSnippet.(track)
  end

  test "is blank for a track without one" do
    track = create :track

    assert_equal "", Track::RetrieveSignUpSnippet.(track)
  end

  test "caches each track's snippet until it syncs to a new commit" do
    track = create :track, synced_to_git_sha: "abc"
    track.expects(:sign_up_snippet).once.returns("one")

    assert_equal "one", Track::RetrieveSignUpSnippet.(track)
    assert_equal "one", Track::RetrieveSignUpSnippet.(track)

    track.update!(synced_to_git_sha: "def")
    track.expects(:sign_up_snippet).once.returns("two")

    assert_equal "two", Track::RetrieveSignUpSnippet.(track)
  end
end
