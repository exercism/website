require "test_helper"

class Exercise::Approach::Contributorship::CreateTest < ActiveSupport::TestCase
  test "idempotent" do
    user = create :user
    approach = create :exercise_approach

    assert_idempotent_command do
      Exercise::Approach::Contributorship::Create.(approach, user)
    end

    assert_equal 1, Exercise::Approach::Contributorship.count
  end
end
