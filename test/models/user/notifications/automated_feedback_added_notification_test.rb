require 'test_helper'

class User::Notifications::AutomatedFeedbackAddedNotificationTest < ActiveSupport::TestCase
  test "essential feedback" do
    user = create :user
    track = create :track, title: "Ruby"
    exercise = create(:concept_exercise, title: "Lasagna", track:)
    solution = create(:concept_solution, exercise:, user:)
    iteration = create :iteration, solution:, idx: 1
    representation = create(:exercise_representation, :with_feedback, feedback_type: :essential, exercise:)

    notification = User::Notifications::AutomatedFeedbackAddedNotification.create!(
      user:,
      params: { representation:, iteration: }
    )

    assert_equal "#{user.id}|automated_feedback_added|Iteration##{iteration.id}", notification.uniqueness_key
    assert_equal "New feedback has been added to iteration (#1) of your solution to <strong>Lasagna</strong> in <strong>Ruby</strong>. We strongly recommend taking a look.", notification.text # rubocop:disable Layout/LineLength
    assert_equal :icon, notification.image_type
    assert_equal exercise.icon_url, notification.image_url
    assert_equal "https://test.exercism.org/tracks/ruby/exercises/strings/iterations", notification.url
    assert_equal "/tracks/ruby/exercises/strings/iterations", notification.path
  end

  test "non-essential feedback" do
    user = create :user
    track = create :track, title: "Ruby"
    exercise = create(:concept_exercise, title: "Lasagna", track:)
    solution = create(:concept_solution, exercise:, user:)
    iteration = create :iteration, solution:, idx: 1
    representation = create(:exercise_representation, :with_feedback, feedback_type: :actionable, exercise:)

    notification = User::Notifications::AutomatedFeedbackAddedNotification.create!(
      user:,
      params: { representation:, iteration: }
    )

    assert_equal "#{user.id}|automated_feedback_added|Iteration##{iteration.id}", notification.uniqueness_key
    assert_equal "New feedback has been added to iteration (#1) of your solution to <strong>Lasagna</strong> in <strong>Ruby</strong>. We recommend taking a look.", notification.text # rubocop:disable Layout/LineLength
    assert_equal :icon, notification.image_type
    assert_equal exercise.icon_url, notification.image_url
    assert_equal "https://test.exercism.org/tracks/ruby/exercises/strings/iterations", notification.url
    assert_equal "/tracks/ruby/exercises/strings/iterations", notification.path
  end

  test "email_should_send? is false when iteration created before 2022-10-01" do
    representation = create :exercise_representation, :with_feedback, feedback_type: :essential, created_at: Time.utc(2021, 5, 7)
    iteration = create :iteration, created_at: Time.utc(2022, 10, 1) - 1.second

    notification = User::Notification::Create.(
      iteration.user,
      :automated_feedback_added,
      iteration:,
      representation:
    )
    notification.status = :unread

    refute notification.email_should_send?
  end

  test "email_should_send? is true when iteration created from 2022-10-01" do
    representation = create :exercise_representation, :with_feedback, feedback_type: :essential, created_at: Time.utc(2021, 5, 7)
    iteration = create :iteration, created_at: Time.utc(2022, 10, 1)

    notification = User::Notification::Create.(
      iteration.user,
      :automated_feedback_added,
      iteration:,
      representation:
    )
    notification.status = :unread

    assert notification.email_should_send?
  end
end
