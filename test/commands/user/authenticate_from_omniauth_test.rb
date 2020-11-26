require "test_helper"

class User::AuthenticateFromOmniauthTest < ActiveSupport::TestCase
  test "creates an auth token for a new user" do
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

    assert_equal 1, User::AuthToken.count
  end

  test "updates email if from users.noreply.github.com" do
    user = create :user, provider: "github", uid: "111", email: "user@users.noreply.github.com"
    auth = stub(provider: "github", uid: "111", info: stub(email: "user@exercism.io"))

    User::AuthenticateFromOmniauth.(auth)

    user.reload
    assert_equal "user@exercism.io", user.email
  end

  test "sets provider and uid for email matches" do
    user = create :user, email: "user@exercism.io"
    auth = stub(provider: "github", uid: "111", info: stub(email: "user@exercism.io"))

    User::AuthenticateFromOmniauth.(auth)

    user.reload
    assert_equal "111", user.uid
    assert_equal "github", user.provider
  end

  test "confirms user and changes password if email matches" do
    SecureRandom.stubs(:uuid).returns("12345678")
    user = create :user, email: "user@exercism.io", confirmed_at: nil
    auth = stub(provider: "github", uid: "111", info: stub(email: "user@exercism.io"))

    User::AuthenticateFromOmniauth.(auth)

    user.reload
    assert user.confirmed?
    assert user.valid_password?("12345678")
  end

  test "does not change password if user confirmed" do
    SecureRandom.stubs(:uuid).returns("12345678")
    user = create :user, email: "user@exercism.io", confirmed_at: Date.new(2016, 12, 25)
    auth = stub(provider: "github", uid: "111", info: stub(email: "user@exercism.io"))

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
