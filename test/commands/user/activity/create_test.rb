require 'test_helper'

class User::Activity::CreateTest < ActiveSupport::TestCase
  include ActionCable::TestHelper

  test "create db record" do
    user = create :user
    type = :started_exercise
    solution = create(:concept_solution)
    exercise = solution.exercise
    params = {
      track: exercise.track,
      exercise:,
      solution:
    }

    User::Activity::Create.(type, user, params)

    # Reload it fresh from the db to avoid caching
    activity = User::Activity.last
    assert_equal user, activity.user
    assert_equal solution, activity.solution
    assert_equal solution.track, activity.track
    assert_instance_of User::Activities::StartedExerciseActivity, activity
    assert_equal 1, activity.version
    assert_equal "#{user.id}|started_exercise|Solution##{solution.id}", activity.uniqueness_key
  end

  test "broadcasts message" do
    # TODO: Readd once the broadcast is added
    skip
    user = create :user
    type = :started_exercise
    exercise = create(:concept_exercise)
    params = { exercise: }
    User::ActivityChannel.expects(:broadcast_changed!).with(user)

    User::Activity::Create.(type, user, params)
  end
end
