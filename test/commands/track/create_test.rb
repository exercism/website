require "test_helper"

class Track::CreateTest < ActiveSupport::TestCase
  test "creates track" do
    Github::Team::Create.stubs(:call)

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

  test "creates contributor team" do
    Github::Team::Create.stubs(:call)

    track = Track::Create.('fsharp', title: 'F#', blurb: 'F# is a functional language', repo_url: 'https://github.com/exercism/fsharp', synced_to_git_sha: 'HEAD', # rubocop:disable Layout/LineLength
                                     tags: ['Compiles to:Binary', 'Runtime:Browser'])

    assert_equal 1, ContributorTeam.find_each.size
    team = ContributorTeam.first
    assert_equal 'F# maintainers', team.name
    assert_equal 'fsharp', team.github_name
    assert_equal :track_maintainers, team.type
    assert_equal track, team.track
  end

  test "creates github team" do
    maintainers_team = mock
    Github::Team.stubs(:new).with('track-maintainers').returns(maintainers_team)
    Github::Team::Create.expects(:call).with("fsharp", "fsharp", parent_team: maintainers_team)

    Track::Create.('fsharp', title: 'F#', blurb: 'F# is a functional language', repo_url: 'https://github.com/exercism/fsharp', synced_to_git_sha: 'HEAD', # rubocop:disable Layout/LineLength
                             tags: ['Compiles to:Binary', 'Runtime:Browser'])
  end

  test "does not create contributor team if track already exists" do
    track = create :track, slug: 'fsharp'
    team = create :contributor_team, name: 'F# maintainers', github_name: 'fsharp', track: track
    updated_at_before_create = team.updated_at

    Track::Create.('fsharp', title: 'F#', blurb: 'F# is a functional language', repo_url: 'https://github.com/exercism/fsharp', synced_to_git_sha: 'HEAD', # rubocop:disable Layout/LineLength
                             tags: ['Compiles to:Binary', 'Runtime:Browser'])

    assert_equal updated_at_before_create, team.reload.updated_at
  end

  test "does not create github team if track already exists" do
    Github::Team::Create.expects(:call).never

    create :track, slug: 'fsharp'

    Track::Create.('fsharp', title: 'F#', blurb: 'F# is a functional language', repo_url: 'https://github.com/exercism/fsharp', synced_to_git_sha: 'HEAD', # rubocop:disable Layout/LineLength
                             tags: ['Compiles to:Binary', 'Runtime:Browser'])
  end

  test "idempotent" do
    Github::Team::Create.stubs(:call)

    assert_idempotent_command do
      Track::Create.('fsharp', title: 'F#', blurb: 'F# is a functional language', repo_url: 'https://github.com/exercism/fsharp', synced_to_git_sha: 'HEAD', # rubocop:disable Layout/LineLength
                               tags: ['Compiles to:Binary', 'Runtime:Browser'])
    end
  end
end
