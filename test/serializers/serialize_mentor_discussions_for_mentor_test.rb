require 'test_helper'

class SerializeMentorDiscussionsForMentorTest < ActiveSupport::TestCase
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
    relationship = create(:mentor_student_relationship, mentor:, student:)

    data = mock
    SerializeMentorDiscussionForMentor.expects(:call).with(discussion, relationship:, has_unseen_post: false).returns(data)
    assert_equal [data], SerializeMentorDiscussionsForMentor.(Mentor::Discussion.all, mentor)
  end

  test "with unseen post" do
    student = create :user
    mentor = create :user
    track = create :track
    exercise = create(:concept_exercise, track:)
    solution = create :concept_solution, exercise:, user: student
    discussion = create(:mentor_discussion, :awaiting_mentor, solution:, mentor:)
    post = create :mentor_discussion_post, discussion:, seen_by_mentor: false

    SerializeMentorDiscussionForMentor.expects(:call).with(discussion, relationship: false, has_unseen_post: true)
    SerializeMentorDiscussionsForMentor.(Mentor::Discussion.all, mentor)

    post.update!(seen_by_mentor: true)
    SerializeMentorDiscussionForMentor.expects(:call).with(discussion, relationship: false, has_unseen_post: false)
    SerializeMentorDiscussionsForMentor.(Mentor::Discussion.all, mentor)
  end
end
