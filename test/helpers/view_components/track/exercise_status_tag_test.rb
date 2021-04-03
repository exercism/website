require "test_helper"

class ViewComponents::Track::ExerciseStatusTagTest < ActionView::TestCase
  include Webpacker::Helper

  test "available" do
    assert_tag(:available, "Available", "available")
  end

  test "locked" do
    assert_tag(:locked, "Locked", "locked")
  end

  test "started" do
    assert_tag(:started, "Started", "started")
  end

  test "in_progress" do
    assert_tag(:in_progress, "In progress", "in-progress")
  end

  test "completed" do
    assert_tag(:completed, "Completed", "completed")
  end

  test "published" do
    assert_tag(:published, "Published", "published")
  end

  test "external" do
    user_track = mock(exercise_status: :external)
    assert_equal "", render(ViewComponents::Track::ExerciseStatusTag.new(nil, user_track))
  end

  def assert_tag(status, text, css_class)
    user_track = mock(exercise_status: status)
    expected = tag.div(text, class: "c-exercise-status-tag --#{css_class}")
    assert_equal expected, render(ViewComponents::Track::ExerciseStatusTag.new(nil, user_track))
  end
end
