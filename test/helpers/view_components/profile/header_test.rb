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

  test "solutions tab" do
    user = create :user, roles: [:must_be_present]
    profile_id = create(:user_profile, user: user).id

    3.times { create :practice_solution, :published, user: user }
    html = render(ViewComponents::Profile::Header.new(user, User::Profile.find(profile_id), nil))
    refute_includes html, "Published Solutions"

    create :practice_solution, :published, user: user
    html = render(ViewComponents::Profile::Header.new(user, User::Profile.find(profile_id), nil))
    assert_includes html, "Published Solutions"
  end

  test "testimonials tab" do
    user = create :user, roles: [:must_be_present]
    profile_id = create(:user_profile, user: user).id

    3.times { create :mentor_testimonial, mentor: user }
    html = render(ViewComponents::Profile::Header.new(user, User::Profile.find(profile_id), nil))
    refute_includes html, "Testimonials"

    create :mentor_testimonial, mentor: user
    html = render(ViewComponents::Profile::Header.new(user, User::Profile.find(profile_id), nil))
    assert_includes html, "Testimonials"
  end

  test "contributions tab" do
    user = create :user, roles: [:must_be_present]
    profile_id = create(:user_profile, user: user).id

    html = render(ViewComponents::Profile::Header.new(user, User::Profile.find(profile_id), nil))
    refute_includes html, "Contributions"

    create :user_code_contribution_reputation_token, user: user
    html = render(ViewComponents::Profile::Header.new(user, User::Profile.find(profile_id), nil))
    assert_includes html, "Contributions"
  end
end
