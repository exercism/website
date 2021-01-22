require 'test_helper'

class SerializeReputationTokenTest < ActiveSupport::TestCase
  test "basic to_hash" do
    exercise = create :concept_exercise
    track = create :track
    token = create :user_reputation_token,
      created_at: Time.current - 1.week,
      exercise: exercise,
      track: track,
      external_link: "https://google.com"

    expected = {
      id: token.uuid,
      value: token.value,
      description: "You authored Datetime",
      icon_name: "sample-exercise-butterflies",
      internal_link: nil,
      external_link: "https://google.com",
      awarded_at: token.created_at.iso8601,
      track: {
        title: track.title,
        icon_name: track.icon_name
      }
    }

    assert_equal expected, SerializeReputationToken.(token)
  end

  test "works with empty token" do
    token = create :user_reputation_token,
      created_at: Time.current - 1.week

    expected = {
      id: token.uuid,
      value: token.value,
      description: "You contributed to Exercism",
      icon_name: :reputation,
      internal_link: nil,
      external_link: nil,
      awarded_at: token.created_at.iso8601,
      track: nil
    }

    assert_equal expected, SerializeReputationToken.(token)
  end
end
