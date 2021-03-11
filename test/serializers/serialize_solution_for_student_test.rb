require 'test_helper'

class SerializeSolutionForStudentTest < ActiveSupport::TestCase
  test "basic to_hash" do
    solution = create :practice_solution, published_at: Time.current - 1.week, completed_at: Time.current
    submission = create :submission, solution: solution

    create :user_track, user: solution.user, track: solution.track
    expected = {
      id: solution.uuid,
      url: "https://test.exercism.io/tracks/ruby/exercises/bob",
      status: :published,
      mentoring_status: 'none',
      num_views: 1270, # TODO
      num_stars: 10, # TODO
      num_comments: 2, # TODO
      num_iterations: 3, # TODO
      num_locs: "9 - 18", # TODO
      last_submitted_at: submission.created_at.iso8601,
      published_at: solution.published_at.iso8601,
      completed_at: solution.completed_at.iso8601,
      has_mentor_discussion_in_progress: false,
      has_mentor_request_pending: false,
      exercise: {
        title: solution.exercise.title,
        icon_name: solution.exercise.icon_name
      },
      track: {
        title: solution.track.title,
        icon_name: solution.track.icon_name
      }
    }

    assert_equal expected, SerializeSolutionForStudent.(solution)
  end

  test "status - started" do
    solution = create :concept_solution
    assert_equal :started, SerializeSolutionForStudent.(solution)[:status]
  end

  test "status - completed" do
    solution = create :concept_solution, completed_at: Time.current
    assert_equal :completed, SerializeSolutionForStudent.(solution)[:status]
  end

  test "status - published" do
    solution = create :concept_solution, completed_at: Time.current, published_at: Time.current
    assert_equal :published, SerializeSolutionForStudent.(solution)[:status]
  end

  test "mentoring discussion in progress" do
    solution = create :concept_solution, completed_at: Time.current, published_at: Time.current
    discussion = create :solution_mentor_discussion, solution: solution
    assert SerializeSolutionForStudent.(solution)[:has_mentor_discussion_in_progress]

    discussion.update!(finished_at: Time.current)
    refute SerializeSolutionForStudent.(solution)[:has_mentor_discussion_in_progress]
  end

  test "mentoring request pending" do
    solution = create :concept_solution, completed_at: Time.current, published_at: Time.current
    request = create :solution_mentor_request, solution: solution
    assert SerializeSolutionForStudent.(solution)[:has_mentor_request_pending]

    request.update!(status: :fulfilled)
    refute SerializeSolutionForStudent.(solution)[:has_mentor_request_pending]
  end
end
