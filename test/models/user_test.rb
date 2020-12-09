require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "#for! with model" do
    user = random_of_many(:user)
    assert_equal user, User.for!(user)
  end

  test "#for! with id" do
    user = random_of_many(:user)
    assert_equal user, User.for!(user.id)
  end

  test "#for! with handle" do
    user = random_of_many(:user)
    assert_equal user, User.for!(user.handle)
  end

  test "reputation sums correctly" do
    user = create :user
    create :user_reputation_acquisition
    create :user_reputation_acquisition, user: user, category: "track_ruby", reason: :exercise_authorship
    create :user_reputation_acquisition, user: user, category: "track_ruby", reason: :exercise_authorship
    create :user_reputation_acquisition, user: user, category: "track_javascript", reason: :exercise_contributorship
    create :user_reputation_acquisition, user: user, category: "docs", reason: :exercise_authorship

    assert_equal 35, user.reputation
    assert_equal 20, user.reputation(track_slug: :ruby)
    assert_equal 10, user.reputation(category: :docs)
  end

  test "reputation raises with both track_slug and category specified" do
    user = create :user

    # Sanity check the individuals work
    # before testing them both together
    assert user.reputation(track_slug: :ruby)
    assert user.reputation(category: :docs)
    assert_raises do
      user.reputation(track_slug: :ruby, category: :docs)
    end
  end

  test "has_badge?" do
    user = create :user
    refute user.has_badge?(:rookie)

    create :rookie_badge, user: user
    assert user.reload.has_badge?(:rookie)
  end

  test "may_view_solution?" do
    user = create :user
    solution = create :concept_solution, user: user
    assert user.may_view_solution?(solution)

    solution = create :concept_solution
    refute user.may_view_solution?(solution)
  end

  test "joined_track?" do
    user = create :user
    user_track = create :user_track, user: user
    track = create :track, :random_slug

    assert user.joined_track?(user_track.track)
    refute user.joined_track?(track)
  end
end
