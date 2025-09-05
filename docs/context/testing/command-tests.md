# Command Tests

Command tests follow the pattern: **setup, execute command, assert**. Focus on:

- **Happy path test**: One test for the main successful scenario
- **Edge case tests**: Every possible failure condition and boundary case
- **Idempotency**: Ensure commands can be run multiple times safely when applicable

## Example

```ruby
class Solution::CreateTest < ActiveSupport::TestCase
  test "creates concept solution successfully" do
    user = create :user
    exercise = create :concept_exercise
    create :user_track, user:, track: exercise.track
    UserTrack.any_instance.expects(:exercise_unlocked?).returns(true)

    solution = Solution::Create.(user, exercise)

    assert solution.is_a?(ConceptSolution)
    assert_equal user, solution.user
    assert_equal exercise, solution.exercise
  end

  test "raises when exercise is locked" do
    user = create :user
    exercise = create :concept_exercise
    create :user_track, user:, track: exercise.track
    UserTrack.any_instance.expects(:exercise_unlocked?).returns(false)

    assert_raises ExerciseLockedError do
      Solution::Create.(user, exercise)
    end
  end

  test "idempotent behavior" do
    user = create :user
    exercise = create :concept_exercise
    create :user_track, user:, track: exercise.track
    UserTrack.any_instance.expects(:exercise_unlocked?).returns(true).twice

    assert_idempotent_command { Solution::Create.(user, exercise) }
  end
end
```
