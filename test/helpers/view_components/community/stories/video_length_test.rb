require "test_helper"

class ViewComponents::Community::Stories::VideoLengthTest < ActionView::TestCase
  test "length less than an ten minutes" do
    story = create :community_story, length_in_minutes: 5
    html = render(ViewComponents::Community::Stories::VideoLength.new(story))
    assert_equal "LENGTH 05MINS", html
  end

  test "length less than an hour" do
    story = create :community_story, length_in_minutes: 34
    html = render(ViewComponents::Community::Stories::VideoLength.new(story))
    assert_equal "LENGTH 34MINS", html
  end

  test "length exactly one hour" do
    story = create :community_story, length_in_minutes: 60
    html = render(ViewComponents::Community::Stories::VideoLength.new(story))
    assert_equal "LENGTH 01HR", html
  end

  test "length greater than one hour" do
    story = create :community_story, length_in_minutes: 75
    html = render(ViewComponents::Community::Stories::VideoLength.new(story))
    assert_equal "LENGTH 01HR 15MINS", html
  end
end
