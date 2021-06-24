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

  test "creates contributor team if track does not exist" do
    track = Track::Create.('fsharp', title: 'F#', blurb: 'F# is a functional language', repo_url: 'https://github.com/exercism/fsharp', synced_to_git_sha: 'HEAD', # rubocop:disable Layout/LineLength
                                     tags: ['Compiles to:Binary', 'Runtime:Browser'])

    assert_equal 1, ContributorTeam.count
    team = ContributorTeam.last
    assert_equal 'fsharp', team.github_name
    assert_equal :track_maintainers, team.type
    assert_equal track, team.track
  end

  test "does not create contributor team if track already exists" do
    track = create :track, slug: 'fsharp'
    team = create :contributor_team, github_name: 'fsharp', track: track
    updated_at_before_create = team.updated_at

    Track::Create.('fsharp', title: 'F#', blurb: 'F# is a functional language', repo_url: 'https://github.com/exercism/fsharp', synced_to_git_sha: 'HEAD', # rubocop:disable Layout/LineLength
                             tags: ['Compiles to:Binary', 'Runtime:Browser'])

    assert_equal updated_at_before_create, team.reload.updated_at
  end

  test "idempotent" do
    assert_idempotent_command do
      Track::Create.('fsharp', title: 'F#', blurb: 'F# is a functional language', repo_url: 'https://github.com/exercism/fsharp', synced_to_git_sha: 'HEAD', # rubocop:disable Layout/LineLength
                               tags: ['Compiles to:Binary', 'Runtime:Browser'])
    end
  end
end
