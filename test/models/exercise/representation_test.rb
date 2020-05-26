require 'test_helper'

class Exercise::RepresentationTest < ActiveSupport::TestCase
  include MarkdownFieldMatchers

  test "has markdown fields for feedback" do
    assert_markdown_field(:exercise_representation, :feedback)
  end

  test "pending?" do
    assert create(:exercise_representation, action: :pending).pending?
    refute create(:exercise_representation, action: :approve).pending?
    refute create(:exercise_representation, action: :disapprove).pending?
  end

  test "approve?" do
    refute create(:exercise_representation, action: :pending).approve?
    assert create(:exercise_representation, action: :approve).approve?
    refute create(:exercise_representation, action: :disapprove).approve?
  end

  test "disapprove?" do
    refute create(:exercise_representation, action: :pending).disapprove?
    refute create(:exercise_representation, action: :approve).disapprove?
    assert create(:exercise_representation, action: :disapprove).disapprove?
  end
end
