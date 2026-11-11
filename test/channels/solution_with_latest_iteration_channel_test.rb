require "test_helper"

class SolutionWithLatestIterationChannelTest < ActionCable::Channel::TestCase
  test "subscribes the solution's owner" do
    solution = create :practice_solution
    stub_connection(current_user: solution.user)

    subscribe uuid: solution.uuid

    assert subscription.confirmed?
    assert_has_stream_for solution
  end

  test "subscribes any mentor while the solution has a pending mentor request" do
    solution = create :practice_solution
    create(:mentor_request, :pending, solution:)
    mentor = create :user, became_mentor_at: Time.current
    stub_connection(current_user: mentor)

    subscribe uuid: solution.uuid

    assert subscription.confirmed?
    assert_has_stream_for solution
  end

  test "subscribes a mentor on the solution's discussion" do
    solution = create :practice_solution
    discussion = create(:mentor_discussion, solution:)
    stub_connection(current_user: discussion.mentor)

    subscribe uuid: solution.uuid

    assert subscription.confirmed?
    assert_has_stream_for solution
  end

  test "rejects a user who cannot view the solution" do
    solution = create :practice_solution
    stub_connection(current_user: create(:user))

    subscribe uuid: solution.uuid

    assert subscription.rejected?
    assert_no_streams
  end

  test "rejects an anonymous connection" do
    solution = create :practice_solution
    stub_connection(current_user: nil)

    subscribe uuid: solution.uuid

    assert subscription.rejected?
    assert_no_streams
  end
end
