require 'test_helper'

class User::Notifications::AutomatedFeedbackAddedNotificationTest < ActiveSupport::TestCase
  test "essential feedback" do
    user = create :user
    track = create :track, title: "Ruby"
    exercise = create :concept_exercise, title: "Lasagna", track: track
    solution = create :concept_solution, exercise: exercise, user: user
    iteration = create :iteration, solution: solution, idx: 1
    representation = create :exercise_representation, :with_feedback, feedback_type: :essential, exercise: exercise

    notification = User::Notifications::AutomatedFeedbackAddedNotification.create!(
      user:,
      params: { representation:, iteration: }
    )

    assert_equal "#{user.id}|automated_feedback_added|Iteration##{iteration.id}", notification.uniqueness_key
    assert_equal "New feedback has been added to iteration (#1) of your solution to <strong>Lasagna</strong> in <strong>Ruby</strong>. We strongly recommend taking a look.", notification.text  # rubocop:disable Layout/LineLength
    assert_equal :icon, notification.image_type
    assert_equal exercise.icon_url, notification.image_url
    assert_equal "https://test.exercism.org/tracks/ruby/exercises/strings/iterations", notification.url
    assert_equal "/tracks/ruby/exercises/strings/iterations", notification.path
  end

  test "non-essential feedback" do
    user = create :user
    track = create :track, title: "Ruby"
    exercise = create :concept_exercise, title: "Lasagna", track: track
    solution = create :concept_solution, exercise: exercise, user: user
    iteration = create :iteration, solution: solution, idx: 1
    representation = create :exercise_representation, :with_feedback, feedback_type: :actionable, exercise: exercise

    notification = User::Notifications::AutomatedFeedbackAddedNotification.create!(
      user:,
      params: { representation:, iteration: }
    )

    assert_equal "#{user.id}|automated_feedback_added|Iteration##{iteration.id}", notification.uniqueness_key
    assert_equal "New feedback has been added to iteration (#1) of your solution to <strong>Lasagna</strong> in <strong>Ruby</strong>. We recommend taking a look.", notification.text  # rubocop:disable Layout/LineLength
    assert_equal :icon, notification.image_type
    assert_equal exercise.icon_url, notification.image_url
    assert_equal "https://test.exercism.org/tracks/ruby/exercises/strings/iterations", notification.url
    assert_equal "/tracks/ruby/exercises/strings/iterations", notification.path
  end
end
