require 'test_helper'

class SerializeMentorDiscussionsForStudentTest < ActiveSupport::TestCase
  test "basic request" do
    student = create :user
    mentor = create :user
    track = create :track
    exercise = create(:concept_exercise, track:)
    solution = create :concept_solution, exercise:, user: student
    discussion = create(:mentor_discussion,
      :awaiting_mentor,
      solution:,
      mentor:)

    data = mock
    SerializeMentorDiscussionForStudent.expects(:call).with(discussion).returns(data)
    assert_equal [data], SerializeMentorDiscussionsForStudent.(Mentor::Discussion.all)
  end

  test "n+1s handled correctly" do
    create_np1_data

    Bullet.profile do
      SerializeMentorDiscussionsForStudent.(Mentor::Discussion.all)
    end
  end
end
