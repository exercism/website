require "test_helper"

class User::AuthenticateFromOmniauthTest < ActiveSupport::TestCase
  test "bootstraps a new user" do
    auth = stub(
      provider: "github",
      uid: "111",
      info: stub(
        email: "user@exercism.io",
        name: "Name",
        nickname: "user22"
      )
    )

    User::Bootstrap.expects(:call).with do |user|
      assert user.is_a?(User)
    end
    User::AuthenticateFromOmniauth.(auth)
  end

  test "creates new user using auth info" do
    auth = stub(
      provider: "github",
      uid: "111",
      info: stub(
        email: "user@exercism.io",
        name: "Name",
        nickname: "user22"
      )
    )

    User::AuthenticateFromOmniauth.(auth)

    user = User.find_by(uid: "111")
    assert_equal "github", user.provider
    assert_equal "111", user.uid
    assert_equal "user@exercism.io", user.email
    assert_equal "Name", user.name
    assert_equal "user22", user.github_username
  end

  test "updates email and github_username if from users.noreply.github.com" do
    user = create :user, provider: "github", uid: "111", email: "user@users.noreply.github.com"
    auth = stub(provider: "github", uid: "111", info: stub(email: "user@exercism.io", nickname: "user22"))

    User::AuthenticateFromOmniauth.(auth)

    user.reload
    assert_equal "user@exercism.io", user.email
    assert_equal "user22", user.github_username
  end

  test "sets provider, uid and github_username for email matches" do
    user = create :user, email: "user@exercism.io"
    auth = stub(provider: "github", uid: "111", info: stub(email: "user@exercism.io", nickname: "user22"))

    User::AuthenticateFromOmniauth.(auth)

    user.reload
    assert_equal "111", user.uid
    assert_equal "github", user.provider
    assert_equal "user22", user.github_username
  end

  test "confirms user and changes password if email matches" do
    SecureRandom.stubs(:uuid).returns("12345678")
    user = create :user, email: "user@exercism.io", confirmed_at: nil
    auth = stub(provider: "github", uid: "111", info: stub(email: "user@exercism.io", nickname: "user22"))

    User::AuthenticateFromOmniauth.(auth)

    user.reload
    assert user.confirmed?
    assert user.valid_password?("12345678")
  end

  test "does not change password if user confirmed" do
    user = create :user, email: "user@exercism.io", github_username: "user22", confirmed_at: Date.new(2016, 12, 25)
    auth = stub(provider: "github", uid: "111", info: stub(email: "user@exercism.io", nickname: "user22"))

    User::AuthenticateFromOmniauth.(auth)

    user.reload
    refute user.valid_password?("12345678")
  end

  test "ensures handle uniqueness" do
    create :user, handle: "user22"
    auth = stub(
      provider: "github",
      uid: "111",
      info: stub(
        email: "user@exercism.io",
        name: "Name",
        nickname: "user22"
      )
    )

    user = User::AuthenticateFromOmniauth.(auth)

    assert user.persisted?
    refute_equal "user22", user.handle
  end
end
