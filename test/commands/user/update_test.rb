require "test_helper"

class User::UpdateTest < ActiveSupport::TestCase
  test "updates user and profile with hash" do
    user = create :user, name: "foobar"
    profile = create :user_profile, user:, twitter: "foobar123"

    User::Update.(
      user,
      user: { name: "iHiD1" },
      profile: { twitter: "iHiD2" }
    )

    assert_equal 'iHiD1', user.name
    assert_equal 'iHiD2', profile.twitter
  end

  test "updates user and profile with params" do
    user = create :user, name: "foobar"
    profile = create :user_profile, user:, twitter: "foobar123"

    User::Update.(
      user,
      ActionController::Parameters.new(user: { name: "iHiD1" }, profile: { twitter: "iHiD2" })
    )

    assert_equal 'iHiD1', user.name
    assert_equal 'iHiD2', profile.twitter
  end

  test "updates user with hash" do
    user = create :user, name: "foobar"
    User::Update.(user, user: { name: "iHiD1" })
    assert_equal 'iHiD1', user.name
  end

  test "updates user with params" do
    user = create :user, name: "foobar"
    User::Update.(user, ActionController::Parameters.new(user: { name: "iHiD1" }))
    assert_equal 'iHiD1', user.name
  end

  test "updates profile with hash" do
    user = create :user, name: "foobar"
    profile = create :user_profile, user:, twitter: "foobar123"
    User::Update.(user, profile: { twitter: "iHiD2" })
    assert_equal 'iHiD2', profile.twitter
  end

  test "updates profile with params" do
    user = create :user, name: "foobar"
    profile = create :user_profile, user:, twitter: "foobar123"
    User::Update.(user, ActionController::Parameters.new(profile: { twitter: "iHiD2" }))
    assert_equal 'iHiD2', profile.twitter
  end

  test "copes with nil params" do
    assert_nothing_raised do
      User::Update.(create(:user), ActionController::Parameters.new(user: nil, profile: nil))
    end
  end
end
