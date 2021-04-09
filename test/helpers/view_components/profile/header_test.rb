require "test_helper"

class ViewComponents::Profile::HeaderTest < ActionView::TestCase
  test "roles" do
    user = create :user, roles: [:must_be_present]
    create :user_profile, user: user

    user.stubs(founder?: true, staff?: true, maintainer?: true)
    html = render(ViewComponents::Profile::Header.new(user, user.profile, nil))
    assert_includes html, "Exercism Founder"
    refute_includes html, "Exercism Staff"
    refute_includes html, "Maintainer"

    user.stubs(founder?: false)
    html = render(ViewComponents::Profile::Header.new(user, user.profile, nil))
    refute_includes html, "Exercism Founder"
    assert_includes html, "Exercism Staff"
    assert_includes html, "Maintainer"

    user.stubs(staff?: false)
    html = render(ViewComponents::Profile::Header.new(user, user.profile, nil))
    refute_includes html, "Exercism Founder"
    refute_includes html, "Exercism Staff"
    assert_includes html, "Maintainer"
  end
end
