require "test_helper"

class Exercise::Representations::SearchTest < ActiveSupport::TestCase
  test "no options returns everything" do
    representation_1 = create :exercise_representation
    representation_2 = create :exercise_representation

    assert_equal [representation_1, representation_2], Exercise::Representations::Search.()
  end

  test "filter: status" do
    representation_1 = create :exercise_representation, feedback_type: nil
    representation_2 = create :exercise_representation, feedback_type: :actionable
    representation_3 = create :exercise_representation, feedback_type: :essential

    assert_equal [representation_1], Exercise::Representations::Search.(status: :feedback_needed)
    assert_equal [representation_2, representation_3], Exercise::Representations::Search.(status: :feedback_submitted)
  end

  test "paginates" do
    25.times { create :exercise_representation }

    first_page = Exercise::Representations::Search.()
    assert_equal 20, first_page.limit_value # Sanity

    assert_equal 20, first_page.length
    assert_equal 1, first_page.current_page
    assert_equal 25, first_page.total_count

    second_page = Exercise::Representations::Search.(page: 2)
    assert_equal 5, second_page.length
    assert_equal 2, second_page.current_page
    assert_equal 25, second_page.total_count
  end
end
