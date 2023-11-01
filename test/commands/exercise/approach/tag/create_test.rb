require "test_helper"

class Exercise::Approach::Tag::CreateTest < ActiveSupport::TestCase
  test "creates new record" do
    approach = create :exercise_approach
    tag = 'construct:while-loop'
    condition_type = :any

    approach_tag = Exercise::Approach::Tag::Create.(approach, tag, condition_type)

    assert_equal 1, Exercise::Approach::Tag.count
    assert_equal tag, approach_tag.tag
    assert_equal condition_type, approach_tag.condition_type
    assert_equal approach, approach_tag.approach
  end

  test "updates condition_type for existing record" do
    approach = create :exercise_approach
    tag = 'construct:while-loop'
    condition_type = :any

    approach_tag = create(:exercise_approach_tag, approach:, tag:, condition_type:)

    Exercise::Approach::Tag::Create.(approach, tag, :not)

    assert_equal :not, approach_tag.reload.condition_type
  end

  test "idempotent" do
    approach = create :exercise_approach

    assert_idempotent_command do
      Exercise::Approach::Tag::Create.(approach, 'construct:if', :all)
    end

    assert_equal 1, Exercise::Approach::Tag.count
  end
end
