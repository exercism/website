require 'test_helper'

class SerializeMentorDiscussionsForMentorTest < ActiveSupport::TestCase
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
    relationship = create :mentor_student_relationship, mentor: mentor, student: student

    data = mock
    SerializeMentorDiscussionForMentor.expects(:call).with(discussion, relationship:).returns(data)
    assert_equal [data], SerializeMentorDiscussionsForMentor.(Mentor::Discussion.all, mentor)
  end
end
