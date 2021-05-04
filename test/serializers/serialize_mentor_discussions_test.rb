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

  test "for mentor" do
    student = create :user
    mentor = create :user
    track = create :track
    exercise = create :concept_exercise, track: track
    solution = create :concept_solution, exercise: exercise, user: student
    discussion = create :mentor_discussion,
      :awaiting_mentor,
      solution: solution,
      mentor: mentor

    links = {
      self: Exercism::Routes.mentoring_discussion_url(discussion),
      posts: Exercism::Routes.api_mentoring_discussion_posts_url(discussion),
      finish: Exercism::Routes.finish_api_mentoring_discussion_url(discussion),
      mark_as_nothing_to_do: Exercism::Routes.mark_as_nothing_to_do_api_mentoring_discussion_url(discussion)
    }

    output = SerializeMentorDiscussion.(discussion, :mentor)
    refute output[:is_finished]
    assert_equal links, output[:links]

    discussion.update(status: :mentor_finished)
    assert SerializeMentorDiscussion.(discussion, :mentor)[:is_finished]
  end

  test "for student" do
    student = create :user
    mentor = create :user
    track = create :track
    exercise = create :concept_exercise, track: track
    solution = create :concept_solution, exercise: exercise, user: student
    discussion = create :mentor_discussion,
      :awaiting_mentor,
      solution: solution,
      mentor: mentor

    links = {
      self: Exercism::Routes.track_exercise_mentor_discussion_url(discussion.track, discussion.exercise, discussion),
      posts: Exercism::Routes.api_solution_discussion_posts_url(discussion.solution.uuid, discussion),
      finish: Exercism::Routes.finish_api_solution_discussion_url(discussion.solution.uuid, discussion.uuid)
    }

    output = SerializeMentorDiscussion.(discussion, :student)
    refute output[:is_finished]
    assert_equal links, output[:links]

    discussion.update(status: :finished)
    assert SerializeMentorDiscussion.(discussion, :student)[:is_finished]
  end
end
