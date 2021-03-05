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
    pr_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    pr_number = 12_312

    track = create :track
    exercise = create :concept_exercise, track: track
    token = create :user_code_contribution_reputation_token,
      created_at: Time.current - 1.week,
      exercise: exercise,
      track: track,
      external_link: "https://google.com",
      params: {
        repo: repo,
        pr_id: pr_id,
        pr_number: pr_number
      }

    expected = {
      id: token.uuid,
      url: "#",
      value: token.value,
      text: "You contributed code via <strong>PR##{pr_number}</strong> on <strong>#{repo}</strong>",
      icon_name: exercise.icon_name,
      internal_link: nil,
      external_link: "https://google.com",
      awarded_at: token.created_at.iso8601,
      is_seen: false,
      track: {
        title: track.title,
        icon_name: track.icon_name
      }
    }.with_indifferent_access

    assert_equal expected, token.rendering_data
  end
end
