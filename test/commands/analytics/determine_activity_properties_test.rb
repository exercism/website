require "test_helper"

class Analytics::DetermineActivityPropertiesTest < ActiveSupport::TestCase
  test "a new user has done nothing yet" do
    assert_equal(
      {
        exercises_completed: 0,
        completed_hello_world: false,
        completed_non_hello_world: false,
        mentoring_sessions: 0
      },
      Analytics::DetermineActivityProperties.(create(:user))
    )
  end

  test "counts completed exercises and tells hello-world apart" do
    user = create :user
    track = create :track
    hello_world = create :practice_exercise, track:, slug: "hello-world"
    bob = create :practice_exercise, track:, slug: "bob"
    leap = create :practice_exercise, track:, slug: "leap"
    create :practice_solution, user:, exercise: hello_world, completed_at: Time.current
    create :practice_solution, user:, exercise: bob, completed_at: Time.current
    create :practice_solution, user:, exercise: leap

    properties = Analytics::DetermineActivityProperties.(user)

    assert_equal 2, properties[:exercises_completed]
    assert properties[:completed_hello_world]
    assert properties[:completed_non_hello_world]
  end

  test "only hello-world" do
    user = create :user
    hello_world = create :practice_exercise, slug: "hello-world"
    create :practice_solution, user:, exercise: hello_world, completed_at: Time.current

    properties = Analytics::DetermineActivityProperties.(user)

    assert properties[:completed_hello_world]
    refute properties[:completed_non_hello_world]
  end

  test "counts mentoring sessions as a student" do
    user = create :user
    solution = create(:practice_solution, user:)
    create(:mentor_discussion, solution:)
    create(:mentor_discussion, solution:)

    assert_equal 2, Analytics::DetermineActivityProperties.(user)[:mentoring_sessions]
  end
end
