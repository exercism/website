require "test_helper"

class ViewComponents::Mentor::HeaderTest < ActionView::TestCase
  test "stats with satisfaction" do
    user = create :user
    user.update(cache: {
      'num_solutions_mentored' => 337,
      'mentor_satisfaction_percentage' => 88
    })
    sign_in! user

    html = render(ViewComponents::Mentor::Header.new(:workspace))
    assert_includes html, "337 discussions completed"
    assert_includes html, "88% satisfaction"
  end

  test "stats without satisfaction" do
    user = create :user
    user.update(cache: {
      'num_solutions_mentored' => 5,
      'mentor_satisfaction_percentage' => nil
    })
    sign_in! user

    html = render(ViewComponents::Mentor::Header.new(:workspace))
    assert_includes html, "5 discussions completed"
    refute_includes html, "satisfaction"
  end

  test "automation tab is unlocked if user is a automator" do
    user = create :user
    create(:user_track_mentorship, :automator, user:)
    sign_in! user

    html = render(ViewComponents::Mentor::Header.new(:automation))
    assert_includes html, 'href="/mentoring/automation"'
  end

  test "automation tab is locked if user not a automator" do
    user = create :user, roles: []
    sign_in! user

    html = render(ViewComponents::Mentor::Header.new(:workspace))
    refute_includes html, 'href="/mentoring/automation"'
  end
end
