require 'test_helper'

class SerializeSolutionActivityTest < ActiveSupport::TestCase
  test "started to_hash" do
    track = create :track, slug: 'ruby'
    exercise = create :concept_exercise, track: track, slug: 'bob'
    solution = create :concept_solution, exercise: exercise

    expected = {
      solution: {
        status: :started,
        mentoring_status: "none",
        num_mentor_comments: 0,
        mentor_comments_unread: false,
        unsubmitted_code: false
      },
      exercise: {
        title: exercise.title,
        icon_name: exercise.icon_name
      },
      activities: nil,
      latest_iteration: nil
    }

    assert_equal expected, SerializeSolutionActivity.(solution)
  end

  test "with mentor comments to_hash" do
    track = create :track, slug: 'ruby'
    exercise = create :concept_exercise, track: track, slug: 'bob'
    solution = create :concept_solution, exercise: exercise
    discussion = create :solution_mentor_discussion, solution: solution

    data = SerializeSolutionActivity.(solution)
    assert_equal 0, data[:solution][:num_mentor_comments]
    refute data[:solution][:mentor_comments_unread]

    create :solution_mentor_discussion_post, discussion: discussion, seen_by_student: true
    data = SerializeSolutionActivity.(solution.reload)
    assert_equal 1, data[:solution][:num_mentor_comments]
    refute data[:solution][:mentor_comments_unread]

    create :solution_mentor_discussion_post, discussion: discussion, seen_by_student: false
    data = SerializeSolutionActivity.(solution.reload)
    assert_equal 2, data[:solution][:num_mentor_comments]
    assert data[:solution][:mentor_comments_unread]
  end

  test "with iteration" do
    track = create :track, slug: 'ruby'
    exercise = create :concept_exercise, track: track, slug: 'bob'
    solution = create :concept_solution, exercise: exercise
    iteration = create :iteration, solution: solution

    data = SerializeSolutionActivity.(solution)
    assert_equal SerializeIteration.(iteration), data[:latest_iteration]
  end
end
