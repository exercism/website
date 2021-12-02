require 'test_helper'

class SerializeMentorDiscussionsForStudentTest < ActiveSupport::TestCase
  test "basic request" do
    student = create :user
    mentor = create :user
    track = create :track
    exercise = create :concept_exercise, track: track
    solution = create :concept_solution, exercise: exercise, user: student
    discussion = create :mentor_discussion,
      :awaiting_mentor,
      solution: solution,
      mentor: mentor

    data = mock
    SerializeMentorDiscussionForStudent.expects(:call).with(discussion).returns(data)
    assert_equal [data], SerializeMentorDiscussionsForStudent.(Mentor::Discussion.all)
  end
end
