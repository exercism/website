require "test_helper"

class User::LinkWithGithubTest < ActiveSupport::TestCase
  test "updates user" do
    provider = 'github'
    uid = '111'
    auth = stub(
      provider:,
      uid:,
      info: stub(nickname: "user22")
    )
    user = create :user

    User::SetGithubUsername.expects(:call).with(user, "user22")

    User::LinkWithGithub.(user, auth)

    assert_equal provider, user.provider
    assert_equal uid, user.uid
  end
end
