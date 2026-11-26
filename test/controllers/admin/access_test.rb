require "test_helper"

class Admin::AccessTest < ActionDispatch::IntegrationTest
  ADMIN_ROUTES = %i[
    admin_donors_url new_admin_donor_url
    admin_users_url search_admin_users_url
    admin_insiders_url
    admin_partners_url
  ].freeze

  MAINTAINER_ADMIN_ROUTES = %i[
    admin_root_url
    admin_community_videos_url
    admin_streaming_events_url
  ].freeze

  ADMIN_ROUTES.each do |route|
    test "#{route}: admins can see it" do
      sign_in!(create(:user, :admin))

      get send(route)

      assert_response :success
    end

    %i[staff maintainer maintainer_admin].each do |role|
      test "#{route}: redirects #{role}" do
        sign_in!(create(:user, role))

        get send(route)

        assert_response :redirect
      end
    end
  end

  MAINTAINER_ADMIN_ROUTES.each do |route|
    %i[admin maintainer_admin].each do |role|
      test "#{route}: #{role} can see it" do
        sign_in!(create(:user, role))

        get send(route)

        assert_response :success
      end
    end

    %i[staff maintainer].each do |role|
      test "#{route}: redirects #{role}" do
        sign_in!(create(:user, role))

        get send(route)

        assert_response :redirect
      end
    end
  end

  test "mailshots: redirects admins other than iHiD" do
    sign_in!(create(:user, :admin))

    get admin_mailshots_url

    assert_redirected_to root_url
  end

  test "mailshots: redirects maintainer admins" do
    sign_in!(create(:user, :maintainer_admin))

    get admin_mailshots_url

    assert_response :redirect
  end
end
