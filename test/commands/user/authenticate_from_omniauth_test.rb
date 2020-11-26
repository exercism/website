require "test_helper"

class User::AuthenticateFromOmniauthTest < ActiveSupport::TestCase
  test "updates email if from users.noreply.github.com" do
    user = create :user, provider: "github", uid: "111", email: "user@users.noreply.github.com"
    auth = stub(provider: "github", uid: "111", info: stub(email: "user@exercism.io"))

    User::AuthenticateFromOmniauth.(auth)

    user.reload
    assert_equal "user@exercism.io", user.email
  end
end
