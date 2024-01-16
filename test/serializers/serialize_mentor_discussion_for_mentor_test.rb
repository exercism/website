require 'test_helper'

class SerializeMentorDiscussionForMentorTest < ActiveSupport::TestCase
  test "basic request" do
    student = create :user
    mentor = create :user
    track = create :track
    exercise = create(:concept_exercise, track:)
    solution = create :concept_solution, exercise:, user: student
    create(:iteration, solution:)
    discussion = create(:mentor_discussion,
      :awaiting_mentor,
      solution:,
      mentor:)
    create(:mentor_discussion_post, discussion:)
    create(:mentor_discussion_post, discussion:)

    output = mock
    SerializeMentorDiscussion.expects(:call).with(
      discussion,
      false,
      discussion.finished_for_mentor?,
      discussion.posts.where(seen_by_mentor: false).exists?,
      {
        self: Exercism::Routes.mentoring_discussion_url(discussion),
        posts: Exercism::Routes.api_mentoring_discussion_posts_url(discussion),
        finish: Exercism::Routes.finish_api_mentoring_discussion_url(discussion),
        mark_as_nothing_to_do: Exercism::Routes.mark_as_nothing_to_do_api_mentoring_discussion_url(discussion),
        tooltip_url: Exercism::Routes.api_mentoring_student_path(discussion.student, track_slug: discussion.track.slug)
      }
    ).returns(output)

    assert_equal output, SerializeMentorDiscussionForMentor.(discussion)
  end

  test "mentored before" do
    student = create :user
    mentor = create :user
    solution = create :concept_solution, user: student
    create(:iteration, solution:)
    discussion = create(:mentor_discussion,
      :awaiting_mentor,
      solution:,
      mentor:)

    relationship = create(:mentor_student_relationship, student:, mentor:)

    result = SerializeMentorDiscussionForMentor.(discussion)
    refute result[:student][:is_favorited]

    relationship.update!(favorited: true)

    result = SerializeMentorDiscussionForMentor.(discussion.reload)
    assert result[:student][:is_favorited]
  end
end
