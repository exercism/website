require 'test_helper'

class SerializeContributorTest < ActiveSupport::TestCase
  test "serializes correctly" do
    rank = 5
    user = create :user
    create(:user_reputation_token, user:)
    generate_reputation_periods!

    expected = {
      rank:,
      activity: "1 PR created",
      handle: user.handle,
      flair: user.flair,
      reputation: "12",
      avatar_url: user.avatar_url,
      links: { profile: nil }
    }

    contextual_data = User::ReputationToken::CalculateContextualData.(user.id)
    assert_equal expected, SerializeContributor.(user, rank:, contextual_data:)
  end

  test "serializes profile link" do
    user = create :user
    create(:user_profile, user:)

    contextual_data = User::ReputationToken::CalculateContextualData.(user.id)
    data = SerializeContributor.(user, rank: 0, contextual_data:)
    assert_equal Exercism::Routes.profile_url(user), data[:links][:profile]
  end

  test "reputation is formatted" do
    user = create :user
    create(:user_profile, user:)

    contextual_data = User::ReputationToken::CalculateContextualData.(user.id)
    contextual_data.stubs(reputation: 1_000_000)
    data = SerializeContributor.(user, rank: 0, contextual_data:)
    assert_equal "1000k", data[:reputation]
  end
end
