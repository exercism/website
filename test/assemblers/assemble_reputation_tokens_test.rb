require "test_helper"

class AssembleContributionsSummaryTest < ActiveSupport::TestCase
  test "renders correctly with data" do
    user = create :user
    token = create :user_reputation_token, user: user

    data = [
      token.rendering_data.merge(
        links: {
          mark_as_seen: Exercism::Routes.mark_as_seen_api_reputation_url(token.uuid)
        }
      )
    ]

    expected = SerializePaginatedCollection.(
      user.reputation_tokens.page(1).per(20),
      data: data,
      meta: {
        links: {
          tokens: Exercism::Routes.reputation_journey_url,
          mark_all_as_seen: Exercism::Routes.mark_all_as_seen_api_reputation_index_url
        },
        total_reputation: user.formatted_reputation,
        is_all_seen: user.reputation_tokens.unseen.empty?
      }
    )

    assert_equal expected, AssembleReputationTokens.(user, {})
  end
end
