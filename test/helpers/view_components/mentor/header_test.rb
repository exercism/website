require_relative "../view_component_test_case"

class ViewComponents::Mentor::HeaderTest < ViewComponentTestCase
  test "stats with satisfaction" do
    user = create :user, num_solutions_mentored: 337, mentor_satisfaction_percentage: 88
    sign_in! user

    html = render(ViewComponents::Mentor::Header.new(:workspace))
    assert_includes html, "337 solutions mentored"
    assert_includes html, "88% satisfaction"
  end
end
