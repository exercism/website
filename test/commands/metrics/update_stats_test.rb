require "test_helper"

class Metrics::UpdateStatsTest < ActiveSupport::TestCase
  test "updates num_users" do
    Metrics::UpdateStats.()
    assert_equal "0", Metrics.num_users

    create_list(:user, 5)
    Metrics::UpdateStats.()
    assert_equal "5", Metrics.num_users
  end

  test "updates num_solutions" do
    Metrics::UpdateStats.()
    assert_equal "0", Metrics.num_solutions

    create_list(:practice_solution, 7)
    Metrics::UpdateStats.()
    assert_equal "7", Metrics.num_solutions
  end

  test "updates num_discussions" do
    Metrics::UpdateStats.()
    assert_equal "0", Metrics.num_discussions

    create_list(:mentor_discussion, 9)
    Metrics::UpdateStats.()
    assert_equal "9", Metrics.num_discussions
  end
end
