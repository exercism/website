require "test_helper"

class AssembleReputationTokensTest < ActiveSupport::TestCase
  test "renders correctly with data" do
    user = create :user
    token = create(:user_reputation_token, user:)

    data = [
      token.rendering_data.merge(
        links: {
          mark_as_seen: Exercism::Routes.mark_as_seen_api_reputation_url(token.uuid)
        }
      )
    ]

    expected = SerializePaginatedCollection.(
      user.reputation_tokens.page(1).per(20),
      data:,
      meta: {
        links: {
          tokens: Exercism::Routes.reputation_journey_url,
          mark_all_as_seen: Exercism::Routes.mark_all_as_seen_api_reputation_index_url
        },
        total_reputation: user.formatted_reputation,
        unseen_total: user.reputation_tokens.unseen.count
      }
    )

    assert_equal expected, AssembleReputationTokens.(user, {})
  end

  test "renders correctly for header" do
    user = create :user
    unseen_token_1 = create(:user_reputation_token, :unseen, user:)
    unseen_token_2 = create(:user_reputation_token, :unseen, user:)
    unseen_token_3 = create(:user_reputation_token, :unseen, user:)
    seen_token_1 = create(:user_reputation_token, :seen, user:)
    seen_token_2 = create(:user_reputation_token, :seen, user:)

    data = [unseen_token_3, unseen_token_2, unseen_token_1, seen_token_2, seen_token_1].map do |token|
      token.rendering_data.merge(
        links: {
          mark_as_seen: Exercism::Routes.mark_as_seen_api_reputation_url(token.uuid)
        }
      )
    end

    expected = SerializePaginatedCollection.(
      user.reputation_tokens.page(1).per(20),
      data:,
      meta: {
        links: {
          tokens: Exercism::Routes.reputation_journey_url,
          mark_all_as_seen: Exercism::Routes.mark_all_as_seen_api_reputation_index_url
        },
        total_reputation: user.formatted_reputation,
        unseen_total: 3
      }
    )

    assert_equal expected, AssembleReputationTokens.(user, { for_header: true })
  end
end
