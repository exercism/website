require 'test_helper'

class Submission::Representation::UpdateMentorTest < ActiveSupport::TestCase
  test "sets mentored_by when a mentor has commented on the iteration" do
    mentor = create :user
    submission = create :submission
    submission_representation = create :submission_representation, submission:, mentored_by: nil
    iteration = create(:iteration, submission:)
    discussion = create(:mentor_discussion, solution: submission.solution, mentor:)
    create(:mentor_discussion_post, discussion:, iteration:)

    Submission::Representation::UpdateMentor.(submission)

    assert_equal mentor, submission_representation.reload.mentored_by
  end

  test "sets mentored_by to nil when no there is no mentoring discussion on the iteration" do
    submission = create :submission
    submission_representation = create(:submission_representation, submission:)
    create(:iteration, submission:)

    Submission::Representation::UpdateMentor.(submission)

    assert_nil submission_representation.reload.mentored_by
  end

  test "sets mentored_by to nil when the mentor has not yet commented on the iteration's mentoring discussion" do
    mentor = create :user
    submission = create :submission
    submission_representation = create(:submission_representation, submission:)
    create(:iteration, submission:)
    create(:mentor_discussion, solution: submission.solution, mentor:)

    Submission::Representation::UpdateMentor.(submission)

    assert_nil submission_representation.reload.mentored_by
  end

  test "don't update mentor when the submission has no iteration" do
    submission = create :submission
    submission_representation = create(:submission_representation, submission:)

    Submission::Representation::UpdateMentor.(submission)

    assert_nil submission_representation.reload.mentored_by
  end

  test "don't update mentor when the submission has no representation" do
    submission = create :submission
    create(:iteration, submission:)

    Submission::Representation::UpdateMentor.(submission)

    assert_nil submission.reload.submission_representation
  end

  test "don't update mentor when the submission has no mentor comment" do
    student = create :user, :not_mentor
    mentor = create :user
    ghost = create :user, :ghost
    submission = create :submission, user: student
    submission_representation = create(:submission_representation, submission:)
    iteration = create(:iteration, submission:)
    discussion = create(:mentor_discussion, solution: submission.solution, mentor:)
    create :mentor_discussion_post, discussion:, iteration:, author: student
    create :mentor_discussion_post, discussion:, iteration:, author: ghost

    Submission::Representation::UpdateMentor.(submission)

    assert_nil submission_representation.reload.mentored_by
  end
end
