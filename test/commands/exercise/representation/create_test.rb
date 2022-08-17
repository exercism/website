require "test_helper"

class Exercise::Representation::CreateTest < ActiveSupport::TestCase
  test "creates representation" do
    exercise = create :practice_exercise
    submission = create :submission, exercise: exercise
    ast = 'def foo'
    ast_digest = 'hq471b'
    mapping = { 'a' => 'test' }

    representation = Exercise::Representation::Create.(submission, ast, ast_digest, mapping)

    assert_equal exercise, representation.exercise
    assert_equal submission, representation.source_submission
    assert_equal ast, representation.ast
    assert_equal ast_digest, representation.ast_digest
    assert_equal mapping, representation.mapping
  end

  test "idempotent" do
    submission = create :submission

    assert_idempotent_command do
      Exercise::Representation::Create.(submission, 'def foo', 'hq471b', { 'a' => 'test' })
    end
  end
end
