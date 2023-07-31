require 'test_helper'

class SerializeSolutionTest < ActiveSupport::TestCase
  test "basic to_hash" do
    solution = create :practice_solution, status: :published, published_iteration_head_tests_status: :passed,
      published_at: Time.current - 1.week, completed_at: Time.current
    submission = create(:submission, solution:)
    iteration = create(:iteration, submission:)

    user_track = create :user_track, user: solution.user, track: solution.track
    expected = {
      uuid: solution.uuid,
      private_url: "https://test.exercism.org/tracks/ruby/exercises/bob",
      public_url: "https://test.exercism.org/tracks/ruby/exercises/bob/solutions/#{solution.user.handle}",
      status: :published,
      published_iteration_head_tests_status: :passed,
      mentoring_status: :none,
      has_notifications: false,
      num_views: solution.num_views,
      num_stars: solution.num_stars,
      num_comments: solution.num_comments,
      num_iterations: solution.num_iterations,
      num_loc: nil,
      published_at: solution.published_at.iso8601,
      completed_at: solution.completed_at.iso8601,
      updated_at: solution.updated_at.iso8601,
      last_iterated_at: iteration.created_at.iso8601,
      is_out_of_date: solution.out_of_date?,
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

    assert_equal expected, SerializeSolution.(solution, user_track:)
  end

  test "num_loc works" do
    solution = create :practice_solution, num_loc: 10
    output = SerializeSolution.(solution)
    assert_equal 10, output[:num_loc]
  end

  test "with no submissions" do
    solution = create :practice_solution, status: :published, published_at: Time.current - 1.week, completed_at: Time.current
    user_track = create :user_track, user: solution.user, track: solution.track

    actual = SerializeSolution.(solution, user_track:)
    assert_nil actual[:last_iterated_at]
  end

  test "with notifications" do
    user = create :user
    track = create :track, :random_slug
    ut_id = create(:user_track, user:, track:).id
    exercise = create(:practice_exercise, track:)
    solution = create(:practice_solution, user:, exercise:)
    discussion = create(:mentor_discussion, solution:)

    # False without user_track
    solution_data = SerializeSolution.(solution)
    refute solution_data[:has_notifications]

    # False with none
    solution_data = SerializeSolution.(solution, user_track: UserTrack.find(ut_id))
    refute solution_data[:has_notifications]

    # Override works
    solution_data = SerializeSolution.(solution, user_track: UserTrack.find(ut_id), has_notifications: true)
    assert solution_data[:has_notifications]

    # True if there is one
    create :mentor_started_discussion_notification, user:, params: { discussion: }, status: :unread
    solution_data = SerializeSolution.(solution, user_track: UserTrack.find(ut_id))
    assert solution_data[:has_notifications]
  end
end
