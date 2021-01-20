require 'test_helper'

class SerializeSolutionsForStudentTest < ActiveSupport::TestCase
  test "basic to_hash" do
    solution = create :practice_solution
    create :user_track, user: solution.user, track: solution.track
    expected = {
      solutions: [{
        id: solution.uuid,
        url: "https://test.exercism.io/tracks/ruby/exercises/bob",
        status: :started,
        mentoring_status: 'none',
        num_views: 1270, # TODO
        num_stars: 10, # TODO
        num_comments: 2, # TODO
        num_iterations: 3, # TODO
        num_locs: "9 - 18", # TODO
        last_submitted_at: solution.submissions.last.try(&:created_at),
        published_at: solution.published_at,
        exercise: {
          title: solution.exercise.title,
          icon_name: solution.exercise.icon_name
        },
        track: {
          title: solution.track.title,
          icon_name: solution.track.icon_name
        }
      }]
    }

    assert_equal expected, SerializeSolutionsForStudent.([solution])
  end

  test "status - started" do
    solution = create :concept_solution
    assert_equal :started, SerializeSolutionsForStudent.([solution])[:solutions][0][:status]
  end

  test "status - completed" do
    solution = create :concept_solution, completed_at: Time.current
    assert_equal :completed, SerializeSolutionsForStudent.([solution])[:solutions][0][:status]
  end

  test "status - published" do
    solution = create :concept_solution, completed_at: Time.current, published_at: Time.current
    assert_equal :published, SerializeSolutionsForStudent.([solution])[:solutions][0][:status]
  end
end
