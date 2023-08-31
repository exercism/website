require 'test_helper'

class Mentor::Discussion::UpdateTimedOutTest < ActiveSupport::TestCase
  [1, 13, 26].each do |num_days_waiting|
    test "do not time out when awaiting student for #{num_days_waiting} days" do
      mentor = create :user
      student = create :user
      discussion = create(:mentor_discussion, :awaiting_student, awaiting_student_since: Time.now.utc - num_days_waiting.days,
        mentor:, student:)

      Mentor::Discussion::UpdateTimedOut.()

      assert_equal :awaiting_student, discussion.status
    end

    test "do not time out when awaiting mentor for #{num_days_waiting} days" do
      mentor = create :user
      student = create :user
      discussion = create(:mentor_discussion, :awaiting_mentor, awaiting_mentor_since: Time.now.utc - num_days_waiting.days, mentor:,
        student:)

      Mentor::Discussion::UpdateTimedOut.()

      assert_equal :awaiting_mentor, discussion.status
    end
  end
end
