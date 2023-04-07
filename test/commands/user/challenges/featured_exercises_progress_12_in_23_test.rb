require "test_helper"

class User::Challenges::FeaturedExercisesProgress12In23Test < ActiveSupport::TestCase
  test "qwe" do
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
end
