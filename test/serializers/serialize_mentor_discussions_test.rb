require 'test_helper'

class SerializeMentorDiscussionsTest < ActiveSupport::TestCase
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

    discussions = Mentor::Discussion::Retrieve.(mentor, :awaiting_mentor, page: 1)

    expected = [SerializeMentorDiscussion.(discussion, student)]

    assert_equal expected, SerializeMentorDiscussions.(discussions, student)
  end
end
