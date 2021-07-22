require "test_helper"

class ViewComponents::Mentor::HeaderTest < ActionView::TestCase
  test "stats with satisfaction" do
    user = create :user, num_solutions_mentored: 337, mentor_satisfaction_percentage: 88
    sign_in! user

    html = render(ViewComponents::Mentor::Header.new(:workspace))
    assert_includes html, "337 solutions mentored"
    assert_includes html, "88% satisfaction"
  end

  test "stats without satisfaction" do
    user = create :user, num_solutions_mentored: 5, mentor_satisfaction_percentage: nil
    sign_in! user

    html = render(ViewComponents::Mentor::Header.new(:workspace))
    assert_includes html, "5 solutions mentored"
    refute_includes html, "satisfaction"
  end
end
