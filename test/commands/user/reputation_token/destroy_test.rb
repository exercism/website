require "test_helper"

class User::ReputationToken::DestroyTest < ActiveSupport::TestCase
  test "destroys token" do
    token = create :user_issue_author_reputation_token

    User::ReputationToken::Destroy.(token)

    refute User::ReputationToken.where(id: token.id).exists?
  end

  test "triggers reputation period updating" do
    token = create :user_issue_author_reputation_token

    User::ReputationPeriod::MarkForToken.expects(:call).with(token)

    User::ReputationToken::Destroy.(token)
  end
end
