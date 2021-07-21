require_relative "../view_component_test_case"

class ViewComponents::Mentor::HeaderTest < ViewComponentTestCase
  %i[workspace queue testimonials guides].each do |selected_tab|
    test "#{selected_tab} tab - stats" do
      user = create :user, num_solutions_mentored: 337, satisfaction_rating: 88
      sign_in! user

      html = render(ViewComponents::Mentor::Header.new(selected_tab))
      assert_includes html, "337 solutions mentored"
      assert_includes html, "88% satisfaction"
    end
  end
end
