require "test_helper"

class User::ReputationToken::AwardForPullRequestTest < ActiveSupport::TestCase
  test "adds code contributions for commits made after synced git SHA" do
    skip

    track = create :track, slug: 'fsharp', synced_to_git_sha: '55494f90e0d0f4b8eddeab2d8883da38483c4984'
    first_user = create :user, handle: "ErikSchierboom", github_username: "erik@schierboom.org"
    second_user = create :user, handle: "SleeplessByte", github_username: "sleepless@byte.org"

    User::ReputationToken::AwardForPullRequest.(track)

    assert first_user.reputation_tokens.find_by(reason: :committed_code,
                                                external_link: "#{track.repo_url}/commit/d34f921e3249f6494026835c1191fe2608f687a9").present? # rubocop:disable Layout/LineLength
    assert first_user.reputation_tokens.find_by(reason: :committed_code,
                                                external_link: "#{track.repo_url}/commit/4afa682a5e45dc4e93d9fe4a7ac3b1b8cdbe1ba8").present? # rubocop:disable Layout/LineLength
    assert second_user.reputation_tokens.find_by(reason: :committed_code,
                                                 external_link: "#{track.repo_url}/commit/300f657115eb82e7a6c8c73e351c19b08de3d077").present? # rubocop:disable Layout/LineLength
  end
end
