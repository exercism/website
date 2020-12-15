require 'test_helper'

class Mentor::RetrieveQueueTest < ActiveSupport::TestCase
  test "only retrieves user's solutions" do
    user = create :user

    valid = create :solution_mentor_discussion, :requires_mentor_action, mentor: user
    create :solution_mentor_discussion, :requires_mentor_action

    assert_equal [valid], Mentor::RetrieveInbox.(user)
  end

  test "only retrieves solutions requiring action" do
    user = create :user

    valid = create :solution_mentor_discussion, :requires_mentor_action, mentor: user
    create :solution_mentor_discussion, mentor: user

    assert_equal [valid], Mentor::RetrieveInbox.(user)
  end
end
