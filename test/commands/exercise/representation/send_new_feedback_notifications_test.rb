require "test_helper"

class Exercise::Representation::SendNewFeedbackNotificationsTest < ActiveSupport::TestCase
  test "send notifications for latest active iterations matching ast digest" do
    representation = create :exercise_representation, :with_feedback, feedback_type: :essential

    user = create :user
    solution = create(:practice_solution, user:)
    submission = create(:submission, exercise: representation.exercise, solution:)
    iteration = create :iteration, submission:, idx: 1
    create :submission_representation, submission:, ast_digest: representation.ast_digest

    perform_enqueued_jobs do
      Exercise::Representation::SendNewFeedbackNotifications.(representation)
    end

    assert_equal 1, User::Notifications::AutomatedFeedbackAddedNotification.where(user:).count
    notification = User::Notifications::AutomatedFeedbackAddedNotification.where(user:).first
    assert_equal user, notification.user
    assert_equal representation, notification.representation
    assert_equal iteration, notification.iteration
  end

  %i[essential actionable].each do |feedback_type|
    test "send notifications when feedback type is #{feedback_type}" do
      representation = create(:exercise_representation, :with_feedback, feedback_type:)

      user = create :user
      solution = create(:practice_solution, user:)
      submission = create(:submission, exercise: representation.exercise, solution:)
      iteration = create :iteration, submission:, idx: 1
      create :submission_representation, submission:, ast_digest: representation.ast_digest

      perform_enqueued_jobs do
        Exercise::Representation::SendNewFeedbackNotifications.(representation)
      end

      assert_equal 1, User::Notifications::AutomatedFeedbackAddedNotification.where(user:).count
      notification = User::Notifications::AutomatedFeedbackAddedNotification.where(user:).first
      assert_equal user, notification.user
      assert_equal representation, notification.representation
      assert_equal iteration, notification.iteration
    end
  end

  test "send notifications for latest active iterations matching ast digest for essential feedback" do
    representation = create :exercise_representation, :with_feedback

    user_1 = create :user
    user_2 = create :user
    solution_1 = create :practice_solution, user: user_1
    solution_2 = create :practice_solution, user: user_2
    submission_1 = create :submission, exercise: representation.exercise, solution: solution_1
    submission_2 = create :submission, exercise: representation.exercise, solution: solution_2
    create :iteration, submission: submission_1, idx: 1
    create :iteration, submission: submission_2, idx: 1
    create :submission_representation, submission: submission_1, ast_digest: representation.ast_digest
    create :submission_representation, submission: submission_2, ast_digest: representation.ast_digest

    perform_enqueued_jobs do
      Exercise::Representation::SendNewFeedbackNotifications.(representation)
    end

    assert_equal 1, User::Notifications::AutomatedFeedbackAddedNotification.where(user: user_1).count
    assert_equal 1, User::Notifications::AutomatedFeedbackAddedNotification.where(user: user_2).count
  end

  test "send notifications for latest active iterations with matching digest created in last two weeks for actionable feedback" do
    representation = create :exercise_representation, :with_feedback

    user_1 = create :user
    user_2 = create :user
    solution_1 = create :practice_solution, user: user_1
    solution_2 = create :practice_solution, user: user_2
    submission_1 = create :submission, exercise: representation.exercise, solution: solution_1
    submission_2 = create :submission, exercise: representation.exercise, solution: solution_2
    create :iteration, submission: submission_1, idx: 1, created_at: Time.zone.now - 1.week
    create :iteration, submission: submission_2, idx: 1, created_at: Time.zone.now - 3.weeks
    create :submission_representation, submission: submission_1, ast_digest: representation.ast_digest
    create :submission_representation, submission: submission_2, ast_digest: representation.ast_digest

    perform_enqueued_jobs do
      Exercise::Representation::SendNewFeedbackNotifications.(representation)
    end

    assert_equal 1, User::Notifications::AutomatedFeedbackAddedNotification.where(user: user_1).count
    assert_equal 0, User::Notifications::AutomatedFeedbackAddedNotification.where(user: user_2).count
  end

  test "does not send notification to iterations matching ast digest that are not latest" do
    representation = create :exercise_representation, :with_feedback

    user = create :user
    solution = create(:practice_solution, user:)
    submission_1 = create(:submission, exercise: representation.exercise, solution:)
    create :iteration, :deleted, submission: submission_1, idx: 1
    create :submission_representation, submission: submission_1, ast_digest: representation.ast_digest
    submission_2 = create(:submission, exercise: representation.exercise, solution:)
    create :iteration, :deleted, submission: submission_2, idx: 2
    create :submission_representation, submission: submission_2, ast_digest: 'different'

    perform_enqueued_jobs do
      Exercise::Representation::SendNewFeedbackNotifications.(representation)
    end

    refute User::Notifications::AutomatedFeedbackAddedNotification.where(user:).exists?
  end

  test "does not send notification to latest iterations matching ast digest that are inactive" do
    representation = create :exercise_representation, :with_feedback

    user = create :user
    solution = create(:practice_solution, user:)
    submission = create(:submission, exercise: representation.exercise, solution:)
    create :iteration, :deleted, submission:, idx: 1
    create :submission_representation, submission:, ast_digest: representation.ast_digest

    perform_enqueued_jobs do
      Exercise::Representation::SendNewFeedbackNotifications.(representation)
    end

    refute User::Notifications::AutomatedFeedbackAddedNotification.where(user:).exists?
  end

  test "does not send notification to iterations with no matching ast digest" do
    representation = create :exercise_representation, :with_feedback

    user = create :user
    solution = create(:practice_solution, user:)
    submission = create(:submission, exercise: representation.exercise, solution:)
    create :iteration, submission:, idx: 1
    create :submission_representation, submission:, ast_digest: 'different_digest'

    perform_enqueued_jobs do
      Exercise::Representation::SendNewFeedbackNotifications.(representation)
    end

    refute User::Notifications::AutomatedFeedbackAddedNotification.where(user:).exists?
  end

  %i[non_actionable celebratory].each do |feedback_type|
    test "does not send notification when feedback type is #{feedback_type}" do
      representation = create(:exercise_representation, :with_feedback, feedback_type:)

      user = create :user
      solution = create(:practice_solution, user:)
      submission = create(:submission, exercise: representation.exercise, solution:)
      create :iteration, submission:, idx: 1
      create :submission_representation, submission:, ast_digest: representation.ast_digest

      perform_enqueued_jobs do
        Exercise::Representation::SendNewFeedbackNotifications.(representation)
      end

      refute User::Notifications::AutomatedFeedbackAddedNotification.where(user:).exists?
    end
  end
end
