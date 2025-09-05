# Model Tests

Model tests focus on testing every public method with small, focused tests. Tests should cover:

- **Happy path behavior**: Normal usage scenarios
- **Edge cases**: Boundary conditions and error states
- **Validations**: Ensure all model validations work correctly
- **Associations**: Test relationships between models
- **Scopes and queries**: Verify custom query methods

## Example

```ruby
class UserTest < ActiveSupport::TestCase
  test "reputation_for_track returns correct value" do
    user = create :user
    track = create :track
    create :user_arbitrary_reputation_token, user:, track:, params: { arbitrary_value: 20 }

    assert_equal 20, user.reputation_for_track(track)
  end

  test "handles nil track gracefully" do
    user = create :user
    assert_equal 0, user.reputation_for_track(nil)
  end
end
```
