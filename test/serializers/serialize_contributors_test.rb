require 'test_helper'

class SerializeContributorsTest < ActiveSupport::TestCase
  test "serializes correctly" do
    user_1 = create :user
    create :user_reputation_token, user: user_1

    user_2 = create :user
    create :user_reputation_token, user: user_2

    contextual_data = User::ReputationToken::CalculateContextualData.([user_1.id, user_2.id])
    expected = [
      SerializeContributor.(user_1, rank: 1, contextual_data: contextual_data[user_1.id]),
      SerializeContributor.(user_2, rank: 2, contextual_data: contextual_data[user_2.id])
    ]

    assert_equal expected, SerializeContributors.(
      [user_1, user_2],
      starting_rank: 1,
      contextual_data:
    )
  end

  test "n+1s handled correctly" do
    create_np1_data

    contextual_data = User::ReputationToken::CalculateContextualData.(User.all)

    Bullet.profile do
      SerializeContributors.(
        User.all,
        starting_rank: 1,
        contextual_data:
      )
    end
  end
end
