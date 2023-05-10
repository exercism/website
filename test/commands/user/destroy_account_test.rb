require "test_helper"

class User::DestroyAccountTest < ActiveSupport::TestCase
  test "resets then destroys" do
    user = create :user

    # Create all the things the person might have
    rel_1 = create :mentor_student_relationship, mentor: user
    rel_2 = create :mentor_student_relationship, student: user
    rel_3 = create :mentor_student_relationship

    User::ResetAccount.expects(:call).with(user)

    User::DestroyAccount.(user)

    assert_raises ActiveRecord::RecordNotFound, &proc { user.reload }
    assert_raises ActiveRecord::RecordNotFound, &proc { rel_1.reload }
    assert_raises ActiveRecord::RecordNotFound, &proc { rel_2.reload }
    assert_nothing_raised { rel_3.reload }
  end

  test "test works without user track" do
    create :user, :ghost

    user = create :user
    solution = create(:practice_solution, user:)
    submission = create(:submission, solution:)
    iteration = create(:iteration, solution:, submission:)
    solution.update!(published_iteration: iteration)

    User::DestroyAccount.(user)
  end
end
