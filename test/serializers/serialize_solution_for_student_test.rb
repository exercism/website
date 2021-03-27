require 'test_helper'

class SerializeSolutionForStudentTest < ActiveSupport::TestCase
  test "basic to_hash" do
    solution = create :practice_solution, status: :published, published_at: Time.current - 1.week, completed_at: Time.current
    submission = create :submission, solution: solution

    create :user_track, user: solution.user, track: solution.track
    expected = {
      id: solution.uuid,
      url: "https://test.exercism.io/tracks/ruby/exercises/bob",
      status: :published,
      mentoring_status: :none,
      has_notifications: true,
      num_views: 1270, # TODO
      num_stars: 10, # TODO
      num_comments: 2, # TODO
      num_iterations: 3, # TODO
      num_locs: "9 - 18", # TODO
      num_mentoring_comments: 2, # TOOD
      last_submitted_at: submission.created_at.iso8601,
      published_at: solution.published_at.iso8601,
      completed_at: solution.completed_at.iso8601,
      has_mentor_discussion_in_progress: false,
      has_mentor_request_pending: false,
      exercise: {
        slug: solution.exercise.slug,
        title: solution.exercise.title,
        icon_url: solution.exercise.icon_url
      },
      track: {
        slug: solution.track.slug,
        title: solution.track.title,
        icon_url: solution.track.icon_url
      }
    }

    assert_equal expected, SerializeSolutionForStudent.(solution)
  end

  test "mentoring discussion in progress" do
    solution = create :concept_solution, mentoring_status: :in_progress
    assert SerializeSolutionForStudent.(solution)[:has_mentor_discussion_in_progress]

    solution.update!(mentoring_status: :finished)
    refute SerializeSolutionForStudent.(solution)[:has_mentor_discussion_in_progress]
  end

  test "mentoring request pending" do
    solution = create :concept_solution, mentoring_status: :requested
    assert SerializeSolutionForStudent.(solution)[:has_mentor_request_pending]

    solution.update!(mentoring_status: :in_progress)
    refute SerializeSolutionForStudent.(solution)[:has_mentor_request_pending]
  end
end
