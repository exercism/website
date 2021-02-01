require 'test_helper'

class SolutionTest < ActiveSupport::TestCase
  %i[concept_solution practice_solution].each do |solution_type|
    test "#{solution_type}: sets uuid" do
      solution = build solution_type, uuid: nil
      assert_nil solution.uuid
      solution.save!
      refute solution.uuid.nil?
    end

    test "#{solution_type}: doesn't override uuid" do
      uuid = "foobar"
      solution = build solution_type, uuid: uuid
      assert_equal uuid, solution.uuid
      solution.save!
      assert_equal uuid, solution.uuid
    end

    test "#{solution_type}: git_slug and git_sha are set correctly" do
      solution = create solution_type
      assert_equal solution.track.git_head_sha, solution.git_sha
      assert_equal solution.exercise.slug, solution.git_slug
    end
  end

  test "update_git_info!" do
    solution = create :concept_solution
    solution.update!(git_sha: "foo", git_slug: "bar")

    # Sanity
    assert_equal "foo", solution.git_sha
    assert_equal "bar", solution.git_slug

    solution.update_git_info!
    assert_equal solution.track.git_head_sha, solution.git_sha
    assert_equal solution.exercise.slug, solution.git_slug
  end

  test "downloaded?" do
    refute create(:concept_solution, downloaded_at: nil).downloaded?
    assert create(:concept_solution, downloaded_at: Time.current).downloaded?
  end

  test "#completed?" do
    refute create(:concept_solution, completed_at: nil).completed?
    assert create(:concept_solution, completed_at: Time.current).completed?
  end

  test "#published?" do
    refute create(:concept_solution, published_at: nil).published?
    assert create(:concept_solution, published_at: Time.current).published?
  end

  test ".completed and .uncompleted scopes" do
    completed = create :concept_solution, completed_at: Time.current
    not_completed = create :concept_solution, completed_at: nil

    assert_equal [completed], Solution.completed
    assert_equal [not_completed], Solution.not_completed
  end

  test ".published scope" do
    published = create(:concept_solution, published_at: Time.current)
    create(:concept_solution, published_at: nil)

    assert [published], Solution.published
  end

  test ".for" do
    user = create :user
    exercise = create :concept_exercise
    create :concept_solution, user: user
    create :concept_solution, exercise: exercise
    solution = create :concept_solution, user: user, exercise: exercise

    assert_equal solution, Solution.for(user, exercise)
  end

  test "anonymised_user_handle" do
    solution_1 = create :concept_solution
    solution_2 = create :concept_solution

    assert_equal solution_1.anonymised_user_handle,
      "anonymous-#{Digest::SHA1.hexdigest("#{solution_1.id}-#{solution_1.uuid}")}"

    assert_equal solution_2.anonymised_user_handle,
      "anonymous-#{Digest::SHA1.hexdigest("#{solution_2.id}-#{solution_2.uuid}")}"
  end

  test "instructions is correct" do
    # TODO: Readd this once we stop using HEAD for all the git stuff
    # Use an old sha to check the right content is returned.
    skip
    solution = create :practice_solution
    assert_equal instructions, solution.instructions
  end

  test "#exercise_solution_files returns exercise files" do
    exercise = create :concept_exercise
    solution = create :concept_solution, exercise: exercise

    expected_files = ["log_line_parser.rb"]
    assert_equal expected_files, solution.exercise_solution_files.keys
    assert solution.exercise_solution_files["log_line_parser.rb"].start_with?("module LogLineParser")
  end

  test "has_in_progress_mentor_discussion" do
    solution = create :concept_solution

    # No discussion
    refute solution.reload.has_in_progress_mentor_discussion?

    # In progress discussion
    discussion = create :solution_mentor_discussion, solution: solution, completed_at: nil
    assert solution.reload.has_in_progress_mentor_discussion?

    # Completed discussion
    discussion.update!(completed_at: Time.current)
    refute solution.reload.has_in_progress_mentor_discussion?
  end

  test "has_pending_mentoring_requests" do
    solution = create :concept_solution

    # No request
    refute solution.reload.has_unlocked_pending_mentoring_request?
    refute solution.reload.has_locked_pending_mentoring_request?

    # No lock
    request = create :solution_mentor_request, locked_until: nil, solution: solution
    assert solution.reload.has_unlocked_pending_mentoring_request?
    refute solution.reload.has_locked_pending_mentoring_request?

    # Expired Lock
    request.update(locked_by: create(:user), locked_until: Time.current - 5.minutes)
    assert solution.reload.has_unlocked_pending_mentoring_request?
    refute solution.reload.has_locked_pending_mentoring_request?

    # Current Lock
    request.update(locked_by: create(:user), locked_until: Time.current + 5.minutes)
    refute solution.reload.has_unlocked_pending_mentoring_request?
    assert solution.reload.has_locked_pending_mentoring_request?

    # Fulfilled
    request.update(status: :fulfilled)
    refute solution.reload.has_unlocked_pending_mentoring_request?
    refute solution.reload.has_locked_pending_mentoring_request?

    # Cancelled
    request.update(status: :cancelled)
    refute solution.reload.has_unlocked_pending_mentoring_request?
    refute solution.reload.has_locked_pending_mentoring_request?
  end

  # The order of the sub-tests in this test are deliberately
  # set to ensure that things are checked in a safe way.
  test "update_mentoring_status!" do
    solution = create :concept_solution
    solution.update_mentoring_status!
    assert_equal 'none', solution.mentoring_status

    discussion = create :solution_mentor_discussion, solution: solution, completed_at: Time.current
    solution.update_mentoring_status!
    assert_equal 'completed', solution.mentoring_status

    request = create :solution_mentor_request, solution: solution
    solution.update_mentoring_status!
    assert_equal 'requested', solution.mentoring_status

    discussion.update(completed_at: nil)
    solution.update_mentoring_status!
    assert_equal 'in_progress', solution.mentoring_status

    discussion.destroy
    request.update(status: :cancelled)
    solution.update_mentoring_status!
    assert_equal 'none', solution.mentoring_status
  end
end
