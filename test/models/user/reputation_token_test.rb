require 'test_helper'

class User::ReputationTokenTest < ActiveSupport::TestCase
  test "text is sanitized" do
    token = User::ReputationToken.new
    token.define_singleton_method(:i18n_params) do
      { user: "<foo>d</foo>angerous" }
    end

    I18n.expects(:t).with(
      "user_reputation_tokens.reputation.",
      user: "dangerous"
    ).returns("")

    token.text
  end

  test "rendering_data" do
    repo = "foo/bar"
    pr_node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    pr_number = 12_312
    title = "The cat on the mat sat"

    track = create :track
    exercise = create(:concept_exercise, track:)
    token = create :user_code_contribution_reputation_token,
      created_at: Time.current - 1.week,
      exercise:,
      track:,
      external_url: "https://google.com",
      params: {
        repo:,
        pr_node_id:,
        pr_number:,
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
    create(:user_reputation_token, user:)

    assert 10, user.reload.reputation
  end

  test "image_url for asset host that is domain" do
    Rails.application.config.action_controller.expects(:asset_host).returns('http://test.exercism.org').at_least_once
    reputation_token = create :user_reputation_token

    assert_equal "http://test.exercism.org/assets/graphics/pull-request-open-8e7b2001eac43dd3a84577f0f5ccfca4c8cc9088.svg",
      reputation_token.rendering_data[:icon_url]
  end

  test "image_url for asset host that is path" do
    Rails.application.config.action_controller.expects(:asset_host).returns('/my-assets').at_least_once
    reputation_token = create :user_reputation_token

    assert_equal "/my-assets/assets/graphics/pull-request-open-8e7b2001eac43dd3a84577f0f5ccfca4c8cc9088.svg",
      reputation_token.rendering_data[:icon_url]
  end

  test "maintains user_tracks.reputation on create, update and destroy" do
    user = create :user
    track = create :track
    user_track = create(:user_track, user:, track:)

    token = create :user_arbitrary_reputation_token, user:, track:,
      params: { arbitrary_value: 20, arbitrary_reason: "" }
    assert_equal 20, user_track.reload.reputation
    assert_equal 20, user.reload.reputation

    other = create :user_arbitrary_reputation_token, user:, track:,
      params: { arbitrary_value: 5, arbitrary_reason: "" }
    assert_equal 25, user_track.reload.reputation

    other.destroy
    assert_equal 20, user_track.reload.reputation
    assert_equal 20, user.reload.reputation

    token.destroy
    assert_equal 0, user_track.reload.reputation
    assert_equal 0, user.reload.reputation
  end

  test "destroy_all decrements user_tracks.reputation" do
    user = create :user
    track = create :track
    user_track = create(:user_track, user:, track:)

    create :user_arbitrary_reputation_token, user:, track:, params: { arbitrary_value: 20, arbitrary_reason: "" }
    create :user_arbitrary_reputation_token, user:, track:, params: { arbitrary_value: 30, arbitrary_reason: "" }
    assert_equal 50, user_track.reload.reputation

    User::ReputationToken.where(user:, track:).destroy_all

    assert_equal 0, user_track.reload.reputation
  end

  test "does not touch other tracks' user_tracks" do
    user = create :user
    track = create :track
    other_track = create :track, :random_slug
    user_track = create(:user_track, user:, track:)
    other_user_track = create(:user_track, user:, track: other_track)

    create :user_arbitrary_reputation_token, user:, track:, params: { arbitrary_value: 20, arbitrary_reason: "" }

    assert_equal 20, user_track.reload.reputation
    assert_equal 0, other_user_track.reload.reputation
  end

  test "a token with no track does not error" do
    user = create :user
    create :user_arbitrary_reputation_token, user:, track: nil, params: { arbitrary_value: 20, arbitrary_reason: "" }

    assert_equal 20, user.reload.reputation
  end
end
