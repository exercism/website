require "test_helper"

class User::ReputationTokens::CodeReviewTokenTest < ActiveSupport::TestCase
  test "creates code review reputation token" do
    external_link = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    repo = 'exercism/v3'
    pr_node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    pr_number = 1347
    pr_title = "The cat sat on the mat"
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::Create.(
      user,
      :code_review,
      repo: repo,
      pr_node_id: pr_node_id,
      pr_number: pr_number,
      pr_title: pr_title,
      external_link: external_link
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_equal User::ReputationTokens::CodeReviewToken, rt.class
    assert_equal "You reviewed <strong>PR##{pr_number}</strong> on <strong>v3</strong>: #{pr_title}", rt.text
    assert_equal 'https://api.github.com/repos/exercism/v3/pulls/1347', rt.external_link
    assert_equal "#{user.id}|code_review|PR#MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ", rt.uniqueness_key
    assert_equal :building, rt.category
    assert_equal :reviewed_code, rt.reason
    assert_equal 3, rt.value
  end
end
