require "test_helper"

class User::UpdateTest < ActiveSupport::TestCase
  test "updates user and profile" do
    user = create :user, name: "foobar"
    profile = create :user_profile, user: user, twitter: "foobar123"

    User::Update.(
      user,
      user: { name: "iHiD1" },
      profile: { twitter: "iHiD2" }
    )

    assert_equal 'iHiD1', user.name
    assert_equal 'iHiD2', profile.twitter
  end

  test "updates user" do
    user = create :user, name: "foobar"

    User::Update.(user, user: { name: "iHiD1" })

    assert_equal 'iHiD1', user.name
  end

  test "updates profile" do
    user = create :user, name: "foobar"
    profile = create :user_profile, user: user, twitter: "foobar123"

    User::Update.(user, profile: { twitter: "iHiD2" })

    assert_equal 'iHiD2', profile.twitter
  end
end
