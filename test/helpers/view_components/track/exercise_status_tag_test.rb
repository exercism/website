require "test_helper"

class ViewComponents::Track::ExerciseStatusTagTest < ActionView::TestCase
  test "available" do
    assert_tag(:available, "Available", "available")
  end

  test "locked" do
    assert_tag(:locked, "Locked", "locked")
  end

  test "in_progress" do
    assert_tag(:iterated, "In-progress", "in-progress")
  end

  test "completed" do
    assert_tag(:completed, "Completed", "completed")
  end

  test "published" do
    assert_tag(:published, "Published", "published")
  end

  test "wip" do
    exercise = create :practice_exercise, status: :wip
    expected = tag.div("Work In Progress", class: "c-exercise-status-tag --wip")
    assert_equal expected, render(ViewComponents::Track::ExerciseStatusTag.new(exercise, nil))
  end

  test "external" do
    exercise = mock(wip?: false)
    user_track = mock(exercise_status: :external)
    assert_equal "", render(ViewComponents::Track::ExerciseStatusTag.new(exercise, user_track))
  end

  def assert_tag(status, text, css_class)
    exercise = mock(wip?: false)
    user_track = mock(exercise_status: status)
    expected = tag.div(text, class: "c-exercise-status-tag --#{css_class}")
    assert_equal expected, render(ViewComponents::Track::ExerciseStatusTag.new(exercise, user_track))
  end
end
