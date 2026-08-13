require "test_helper"

class Exercise::Representation::RecacheTest < ActiveSupport::TestCase
  test "defers subsequent commands" do
    representation = create(:exercise_representation)

    # Add new solution so that the count changes
    create :concept_solution, :published, published_exercise_representation: representation

    Exercise::Representation::UpdateNumSubmissions.expects(:defer).with(representation)
    Exercise::Representation::SyncToSearchIndex.expects(:defer).with(representation)

    Exercise::Representation::Recache.(representation)
  end

  test "doesn't call follow ups if nothing changes" do
    representation = create(:exercise_representation)

    Exercise::Representation::UpdateNumSubmissions.expects(:defer).never
    Exercise::Representation::SyncToSearchIndex.expects(:defer).never

    Exercise::Representation::Recache.(representation)
  end

  test "force calls follow ups even if nothing changes" do
    representation = create(:exercise_representation)

    Exercise::Representation::UpdateNumSubmissions.expects(:defer).with(representation)
    Exercise::Representation::SyncToSearchIndex.expects(:defer).with(representation)

    Exercise::Representation::Recache.(representation, force: true)
  end

  test "doesn't change last_submitted_at if not provided" do
    last_submitted_at = Time.current - 1.week
    representation = create(:exercise_representation, last_submitted_at:)

    Exercise::Representation::Recache.(representation)

    assert_equal last_submitted_at, representation.last_submitted_at
  end

  test "sets last_submitted_at" do
    representation = create(:exercise_representation, last_submitted_at: Time.current - 2.weeks)

    last_submitted_at = Time.current - 1.week

    Exercise::Representation::Recache.(representation, last_submitted_at:)

    assert_equal last_submitted_at, representation.last_submitted_at
  end

  test "uses num_published_solutions" do
    representation = create(:exercise_representation, oldest_solution: create(:practice_solution))

    3.times do
      solution = create :practice_solution, :published, user: create(:user),
        published_exercise_representation: representation,
        published_iteration_head_tests_status: :passed
      submission = create(:submission, solution:)
      create(:submission_file, submission:, content: "foo")
      create(:iteration, submission:)
    end

    # Unpublished
    solution = create :practice_solution, user: create(:user),
      published_exercise_representation: representation,
      published_iteration_head_tests_status: :passed
    submission = create(:submission, solution:)
    create(:submission_file, submission:, content: "foo")
    create(:iteration, submission:)

    Exercise::Representation::Recache.(representation)

    assert_equal 3, representation.num_published_solutions
  end

  test "correctly chooses presigtious solution" do
    representation = create(:exercise_representation)
    track = representation.track

    users = create_list(:user, 3) do |user|
      solution = create :practice_solution, :published, user:,
        published_exercise_representation: representation,
        published_iteration_head_tests_status: :passed
      submission = create(:submission, solution:)
      create(:submission_file, submission:, content: "foo")
      create(:iteration, submission:)
      create(:user_track, user:, track:)
    end

    # Should default to oldest solution if everyone's rep is the same
    Exercise::Representation::Recache.(representation)
    assert_equal users[0].solutions.first, representation.prestigious_solution

    create :user_arbitrary_reputation_token, user: users[0], track:, params: { arbitrary_value: 20, arbitrary_reason: "" }
    create :user_arbitrary_reputation_token, user: users[1], track:, params: { arbitrary_value: 18, arbitrary_reason: "" }
    create :user_arbitrary_reputation_token, user: users[1], track:, params: { arbitrary_value: 30, arbitrary_reason: "" }
    create :user_arbitrary_reputation_token, user: users[2], track:, params: { arbitrary_value: 13, arbitrary_reason: "" }

    # And then be the solution of the highest rated user
    Exercise::Representation::Recache.(representation)
    assert_equal users[1].solutions.first, representation.prestigious_solution
  end

  test "prestigious solution ignores reputation on other tracks" do
    representation = create(:exercise_representation)
    track = representation.track
    other_track = create(:track, :random_slug)

    users = create_list(:user, 2) do |user|
      solution = create :practice_solution, :published, user:,
        published_exercise_representation: representation,
        published_iteration_head_tests_status: :passed
      submission = create(:submission, solution:)
      create(:submission_file, submission:, content: "foo")
      create(:iteration, submission:)
      create(:user_track, user:, track:)
      create(:user_track, user:, track: other_track)
    end

    create :user_arbitrary_reputation_token, user: users[0], track:, params: { arbitrary_value: 5, arbitrary_reason: "" }
    create :user_arbitrary_reputation_token, user: users[1], track: other_track,
      params: { arbitrary_value: 500, arbitrary_reason: "" }

    Exercise::Representation::Recache.(representation)
    assert_equal users[0].solutions.first, representation.prestigious_solution
  end

  test "prestigious solution scores a published solver with no user_track as zero" do
    representation = create(:exercise_representation)
    track = representation.track

    users = create_list(:user, 2) do |user|
      solution = create :practice_solution, :published, user:,
        published_exercise_representation: representation,
        published_iteration_head_tests_status: :passed
      submission = create(:submission, solution:)
      create(:submission_file, submission:, content: "foo")
      create(:iteration, submission:)
    end

    # users[1] has track reputation but has never joined the track, so has
    # no user_tracks row and therefore scores zero. users[0] has joined and
    # has less raw reputation, but wins.
    create(:user_track, user: users[0], track:)
    create :user_arbitrary_reputation_token, user: users[0], track:, params: { arbitrary_value: 1, arbitrary_reason: "" }
    create :user_arbitrary_reputation_token, user: users[1], track:, params: { arbitrary_value: 100, arbitrary_reason: "" }

    Exercise::Representation::Recache.(representation)
    assert_equal users[0].solutions.first, representation.prestigious_solution
  end

  test "prestigious solution falls back to oldest solution when nobody has track reputation" do
    representation = create(:exercise_representation)
    track = representation.track

    users = create_list(:user, 2) do |user|
      solution = create :practice_solution, :published, user:,
        published_exercise_representation: representation,
        published_iteration_head_tests_status: :passed
      submission = create(:submission, solution:)
      create(:submission_file, submission:, content: "foo")
      create(:iteration, submission:)
      create(:user_track, user:, track:)
    end

    Exercise::Representation::Recache.(representation)

    assert_equal users[0].solutions.first, representation.oldest_solution
    assert_equal users[0].solutions.first, representation.prestigious_solution
  end

  test "chooses correct oldest solution" do
    representation = create(:exercise_representation)

    # Ghost user
    create :practice_solution, :published,
      user: create(:user, :ghost),
      published_exercise_representation: representation,
      published_iteration_head_tests_status: :passed

    # Correct one!
    solution = create :practice_solution, :published,
      published_exercise_representation: representation,
      published_iteration_head_tests_status: :passed
    submission = create(:submission, solution:)
    create(:submission_file, submission:, content: "foo")
    create(:iteration, submission:)

    Exercise::Representation::Recache.(representation)

    assert_equal solution, representation.oldest_solution

    # Defaults presigtious to oldest solution with no rep periods
    assert_equal solution, representation.prestigious_solution
  end

  test "correctly unsets solutions" do
    representation = create :exercise_representation,
      oldest_solution: create(:practice_solution),
      prestigious_solution: create(:practice_solution)

    Exercise::Representation::Recache.(representation)

    assert_nil representation.oldest_solution
    assert_nil representation.prestigious_solution
  end
end
