require 'test_helper'

class User::Activity::CreateTest < ActiveSupport::TestCase
  include ActionCable::TestHelper

  test "create db record" do
    user = create :user
    type = :started_exercise
    exercise = create(:concept_exercise)
    params = {
      track: exercise.track,
      exercise: exercise
    }

    activity = User::Activity::Create.(type, user, params)

    assert_equal 1, User::Activity.count
    assert_equal user, activity.user
    assert_equal exercise.track, activity.track
    assert_equal User::Activities::StartedExerciseActivity, activity.class
    assert_equal 1, activity.version
    assert_equal "#{user.id}|started_exercise|Exercise##{exercise.id}", activity.uniqueness_key
    assert_equal params, activity.send(:params)
  end

  test "broadcasts message" do
    # TODO: Readd once the broadcast is added
    skip
    user = create :user
    type = :started_exercise
    exercise = create(:concept_exercise)
    params = { exercise: exercise }
    User::ActivityChannel.expects(:broadcast_changed).with(user)

    User::Activity::Create.(type, user, params)
  end
end
