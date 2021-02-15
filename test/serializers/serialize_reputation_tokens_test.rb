require 'test_helper'

class SerializeReputationTokensTest < ActiveSupport::TestCase
  test "basic to_hash" do
    repo = "foo/bar"
    pr_id = 12_312

    track = create :track
    exercise = create :concept_exercise, track: track
    token = create :user_code_contribution_reputation_token,
      created_at: Time.current - 1.week,
      exercise: exercise,
      track: track,
      external_link: "https://google.com",
      params: {
        repo: repo,
        pr_id: pr_id
      }

    expected = [
      {
        id: token.uuid,
        value: token.value,
        text: "You contributed code via <strong>PR##{pr_id}</strong> on <strong>#{repo}</strong>",
        icon_name: "sample-exercise-rocket",
        internal_link: nil,
        external_link: "https://google.com",
        awarded_at: token.created_at.iso8601,
        track: {
          title: track.title,
          icon_name: track.icon_name
        }
      }.with_indifferent_access
    ]

    assert_equal expected, SerializeReputationTokens.([token])
  end
end
