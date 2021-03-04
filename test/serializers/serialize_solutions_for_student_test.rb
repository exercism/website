require 'test_helper'

class SerializeSolutionsForStudentTest < ActiveSupport::TestCase
  test "basic to_hash" do
    solution = create :practice_solution, published_at: Time.current - 1.week, completed_at: Time.current - 1.week
    submission = create :submission, solution: solution

    create :user_track, user: solution.user, track: solution.track
    expected = [
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
      completed_at: solution.completed_at.iso8601,
      published_at: solution.published_at.iso8601,
      exercise: {
        title: solution.exercise.title,
        icon_name: solution.exercise.icon_name
      },
      track: {
        title: solution.track.title,
        icon_name: solution.track.icon_name
      }
    ]

    assert_equal expected, SerializeSolutionsForStudent.([solution])
  end

  test "status - started" do
    solution = create :concept_solution
    assert_equal :started, SerializeSolutionsForStudent.([solution])[0][:status]
  end

  test "status - completed" do
    solution = create :concept_solution, completed_at: Time.current
    assert_equal :completed, SerializeSolutionsForStudent.([solution])[0][:status]
  end

  test "status - published" do
    solution = create :concept_solution, completed_at: Time.current, published_at: Time.current
    assert_equal :published, SerializeSolutionsForStudent.([solution])[0][:status]
  end
end
