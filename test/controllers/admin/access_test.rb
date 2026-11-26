require "test_helper"

class Admin::AccessTest < ActionDispatch::IntegrationTest
  ADMIN_ROUTES = %i[
    admin_users_url search_admin_users_url
    admin_partners_url
  ].freeze

  MAINTAINER_ADMIN_ROUTES = %i[
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

  MAINTAINER_ROUTES = %i[
    admin_root_url
    admin_site_updates_url
    admin_track_categories_url
    admin_track_maintainers_url
    admin_submissions_url
  ].freeze

  MAINTAINER_ROUTES.each do |route|
    test "#{route}: maintainers can see it" do
      sign_in!(create(:user, :maintainer))

      get send(route)

      assert_response :success
    end

    test "#{route}: redirects staff" do
      sign_in!(create(:user, :staff))

      get send(route)

      assert_redirected_to root_url
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
