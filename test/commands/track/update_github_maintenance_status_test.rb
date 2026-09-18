require "test_helper"

class Track::UpdateGithubMaintenanceStatusTest < ActiveSupport::TestCase
  test "promotes unmaintained repo to maintained when track has a maintainer" do
    track = create(:track, slug: 'fortran')
    create(:github_team_member, team_name: 'fortran')

    stub_topics('fortran', %w[exercism-track community-contributions-paused unmaintained])
    put = stub_replace_topics('fortran', %w[exercism-track community-contributions-paused maintained])

    Track::UpdateGithubMaintenanceStatus.(track)

    assert_requested put
  end

  test "demotes maintained repo to unmaintained when track has no maintainers" do
    track = create(:track, slug: 'fortran')

    stub_topics('fortran', %w[exercism-track maintained])
    put = stub_replace_topics('fortran', %w[exercism-track unmaintained])

    Track::UpdateGithubMaintenanceStatus.(track)

    assert_requested put
  end

  test "does nothing when already maintained and has a maintainer" do
    track = create(:track, slug: 'fortran')
    create(:github_team_member, team_name: 'fortran')

    stub_topics('fortran', %w[exercism-track maintained])

    Track::UpdateGithubMaintenanceStatus.(track)
    # No PUT stubbed, so WebMock raises if replace_all_topics is called
  end

  test "does nothing when already unmaintained and has no maintainers" do
    track = create(:track, slug: 'fortran')

    stub_topics('fortran', %w[exercism-track unmaintained])

    Track::UpdateGithubMaintenanceStatus.(track)
  end

  test "leaves nuanced maintained categories untouched" do
    track = create(:track, slug: 'fortran')
    # No team members, but the track is deliberately labelled solitary/autonomous
    %w[maintained-solitary maintained-autonomous wip-track].each do |category|
      stub_topics('fortran', ['exercism-track', category])

      Track::UpdateGithubMaintenanceStatus.(track)
      # No PUT stubbed for any of these, so WebMock raises on a write
    end
  end

  test "does nothing in development" do
    track = create(:track, slug: 'fortran')
    Rails.env.stubs(:development?).returns(true)

    Track::UpdateGithubMaintenanceStatus.(track)
    # No API calls stubbed - WebMock raises if any are made
  end

  private
  def stub_topics(slug, names)
    stub_request(:get, %r{https://api\.github\.com/repos/exercism/#{slug}/topics}).
      to_return(
        status: 200,
        body: { names: }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )
  end

  def stub_replace_topics(slug, expected_names)
    stub_request(:put, "https://api.github.com/repos/exercism/#{slug}/topics").
      with { |request| JSON.parse(request.body)["names"] == expected_names }.
      to_return(status: 200, body: { names: expected_names }.to_json, headers: { 'Content-Type': 'application/json' })
  end
end
