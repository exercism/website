require 'test_helper'

class SerializePublicUserTest < ActiveSupport::TestCase
  test "serializes a user with no reputation" do
    user = create :user, handle: 'iHiD'

    expected = {
      handle: 'iHiD',
      avatar_url: user.avatar_url,
      flair: nil,
      has_profile: false,
      reputation: {
        total: "0",
        tracks: {}
      }
    }
    assert_equal expected, SerializePublicUser.(user)
  end

  test "serializes flair, profile and per-track reputation" do
    user = create :user, handle: 'iHiD', flair: :insider
    create(:user_profile, user:)

    ruby = create :track, slug: 'ruby'
    js = create :track, slug: 'javascript', title: "JavaScript"
    create(:user_track, user:, track: ruby)
    create(:user_track, user:, track: js)
    create(:user_reputation_token, user:, track: ruby, level: :medium)
    create(:user_reputation_token, user:, track: ruby, level: :medium)
    create(:user_reputation_token, user:, track: js, level: :medium)

    # Reputation with no track should not appear in the tracks map
    create(:user_reputation_token, user:, track: nil, level: :medium)

    serialized = SerializePublicUser.(user.reload)

    assert_equal 'iHiD', serialized[:handle]
    assert_equal :insider, serialized[:flair]
    assert serialized[:has_profile]
    assert_equal user.formatted_reputation, serialized[:reputation][:total]
    assert_equal %w[ruby javascript].sort, serialized[:reputation][:tracks].keys.sort
    assert_equal user.reputation_for_track(ruby), serialized[:reputation][:tracks]['ruby']
    assert_equal user.reputation_for_track(js), serialized[:reputation][:tracks]['javascript']
  end

  test "uses a single query for all tracks" do
    user = create :user
    ruby = create :track, slug: 'ruby'
    js = create :track, slug: 'javascript', title: "JavaScript"
    create(:user_reputation_token, user:, track: ruby)
    create(:user_reputation_token, user:, track: js)

    queries = []
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |*, payload|
      queries << payload[:sql] if payload[:sql].include?("user_reputation_tokens")
    end
    SerializePublicUser.(user.reload)
    ActiveSupport::Notifications.unsubscribe(subscriber)

    assert_equal 1, queries.size
  end
end
