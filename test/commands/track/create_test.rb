require "test_helper"

class Track::CreateTest < ActiveSupport::TestCase
  test "creates track" do
    Track::Create.('fsharp', title: 'F#', blurb: 'F# is a functional language', repo_url: 'https://github.com/exercism/fsharp', synced_to_git_sha: 'HEAD', # rubocop:disable Layout/LineLength
                             tags: ['Compiles to:Binary', 'Runtime:Browser'])

    assert_equal 1, Track.count
    track = Track.last

    assert_equal 'fsharp', track.slug
    assert_equal 'F#', track.title
    assert_equal 'F# is a functional language', track.blurb
    assert_equal 'https://github.com/exercism/fsharp', track.repo_url
    assert_equal 'HEAD', track.synced_to_git_sha
    assert_equal ['Compiles to:Binary', 'Runtime:Browser'], track.tags
  end

  test "idempotent" do
    assert_idempotent_command do
      Track::Create.('fsharp', title: 'F#', blurb: 'F# is a functional language', repo_url: 'https://github.com/exercism/fsharp', synced_to_git_sha: 'HEAD', # rubocop:disable Layout/LineLength
                               tags: ['Compiles to:Binary', 'Runtime:Browser'])
    end
  end
end
