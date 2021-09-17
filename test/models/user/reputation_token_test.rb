require 'test_helper'

class User::ReputationTokenTest < ActiveSupport::TestCase
  test "text is sanitized" do
    token = User::ReputationToken.new
    token.define_singleton_method(:i18n_params) do
      { user: "<foo>d</foo>angerous" }
    end

    I18n.expects(:t).with(
      "user_reputation_tokens.reputation.",
      { user: "dangerous" }
    ).returns("")

    token.text
  end

  test "rendering_data" do
    repo = "foo/bar"
    pr_node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    pr_number = 12_312
    title = "The cat on the mat sat"

    track = create :track
    exercise = create :concept_exercise, track: track
    token = create :user_code_contribution_reputation_token,
      created_at: Time.current - 1.week,
      exercise: exercise,
      track: track,
      external_url: "https://google.com",
      params: {
        repo: repo,
        pr_node_id: pr_node_id,
        pr_number: pr_number,
        pr_title: title,
        merged_at: Time.parse('2020-04-03T14:54:57Z').utc
      }

    expected = {
      uuid: token.uuid,
      value: token.value,
      text: "You created <strong>PR##{pr_number}</strong> on <strong>bar</strong>: #{title}",
      icon_url: exercise.icon_url,
      internal_url: nil,
      external_url: "https://google.com",
      created_at: token.created_at.iso8601,
      is_seen: false,
      track: {
        title: track.title,
        icon_url: track.icon_url
      }
    }.with_indifferent_access

    assert_equal expected, token.rendering_data
  end

  test "seen! marks as seen" do
    token = create :user_reputation_token
    refute token.seen?

    token.seen!
    assert token.reload.seen?
  end

  test "seen! doesn't recalculate everything" do
    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      token = create :user_reputation_token

      token.expects(:cacheable_rendering_data).never

      token.seen!
    end
  end

  test "updates user's reputation" do
    user = create :user, handle: "User22", github_username: "user22"
    create :user_reputation_token, user: user

    assert 10, user.reload.reputation
  end
end
