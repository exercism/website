require 'test_helper'

class SerializeContributorTest < ActiveSupport::TestCase
  test "serializes correctly without data passed in" do
    rank = 5
    user = create :user
    create :user_reputation_token, user: user

    expected = {
      rank: rank,
      activities: "1 PR created",
      handle: user.handle,
      reputation: 0,
      avatar_url: user.avatar_url,
      links: { profile: nil }
    }

    assert_equal expected, SerializeContributor.(user, rank)
  end

  test "serializes profile link" do
    user = create :user
    create :user_profile, user: user

    data = SerializeContributor.(user, 0)
    assert_equal Exercism::Routes.profile_url(user), data[:links][:profile]
  end

  test "serializes contributors" do
    user = create :user
    create :user_code_contribution_reputation_token, user: user
    2.times { create :user_code_merge_reputation_token, user: user }
    3.times { create :user_code_review_reputation_token, user: user }
    4.times { create :user_exercise_author_reputation_token, user: user }
    5.times { create :user_exercise_contribution_reputation_token, user: user }
    6.times { create :user_mentored_reputation_token, user: user }
    7.times { create :user_published_solution_reputation_token, user: user }
    data = SerializeContributor.(user, 0)
    assert_equal "1 PR created • 3 PRs reviewed • 2 PRs merged • 4 exercises authored • 5 exercise contributions • 6 solutions mentored • 7 solutions published", data[:activities] # rubocop:disable Layout/LineLength
  end
end
