require "test_helper"

class Exercise::Approach::Authorship::CreateTest < ActiveSupport::TestCase
  test "idempotent" do
    user = create :user
    approach = create :exercise_approach

    assert_idempotent_command do
      Exercise::Approach::Authorship::Create.(approach, user)
    end

    assert_equal 1, Exercise::Approach::Authorship.count
  end
end
