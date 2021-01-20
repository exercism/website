require 'test_helper'

class SerializeReputationTokensTest < ActiveSupport::TestCase
  test "basic to_hash" do
    exercise = create :concept_exercise
    token = create :user_reputation_token,
      created_at: Time.current - 1.week,
      exercise: exercise,
      external_link: "https://google.com"

    expected = {
      tokens: [{
        value: token.value,
        description: "You authored Datetime",
        icon_name: "sample-exercise-butterflies",
        link_url: "https://google.com",
        awarded_at: token.created_at.iso8601
      }]
    }

    assert_equal expected, SerializeReputationTokens.([token])
  end
end
