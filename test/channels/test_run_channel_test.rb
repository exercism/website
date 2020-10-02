require "test_helper"

class TestRunChannelTest < ActionCable::Channel::TestCase
  test ".broadcast! broadcasts test run" do
    test_run = create :iteration_test_run,
      ops_status: 403,
      raw_results: { message: nil }

    assert_broadcast_on(
      'test_run',
      test_run: { id: test_run.id, status: "ops_error", message: "Some error occurred", tests: nil }
    ) do
      TestRunChannel.broadcast!(test_run)
    end
  end
end
