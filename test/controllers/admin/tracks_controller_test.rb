require "test_helper"

class Admin::TracksControllerTest < ActionDispatch::IntegrationTest
  test "new: redirects maintainers" do
    sign_in!(create(:user, :maintainer))

    get new_admin_track_path

    assert_redirected_to admin_root_path
  end

  test "new: shows the form to maintainer admins" do
    sign_in!(create(:user, :maintainer_admin))

    get new_admin_track_path

    assert_response :success
    assert_select "input[name=slug]"
  end

  test "new: lists recently added tracks" do
    track = create :track, slug: "common-lisp", title: "Common Lisp"
    sign_in!(create(:user, :maintainer_admin))

    get new_admin_track_path

    assert_select "table.c-admin-table td", text: track.title
  end

  test "create: queues the track to be added" do
    sign_in!(create(:user, :maintainer_admin))

    assert_enqueued_with(job: MandateJob) do
      post admin_tracks_path, params: { slug: " Common-Lisp " }
    end

    assert_redirected_to new_admin_track_path
    assert_equal 'The "common-lisp" track has been queued to be added. ' \
                 "It will appear below once it has been created, usually within a few minutes.", flash[:notice]
  end

  test "create: redirects maintainers without queueing anything" do
    sign_in!(create(:user, :maintainer))

    assert_no_enqueued_jobs do
      post admin_tracks_path, params: { slug: "common-lisp" }
    end

    assert_redirected_to admin_root_path
  end

  ["", "Common Lisp", "common_lisp", "-lisp", "lisp-", "common--lisp", "lisp/../ruby"].each do |slug|
    test "create: rejects the slug #{slug.inspect}" do
      sign_in!(create(:user, :maintainer_admin))

      assert_no_enqueued_jobs do
        post admin_tracks_path, params: { slug: }
      end

      assert_response :unprocessable_entity
      assert_select ".c-flash .--errors"
    end
  end

  test "create: rejects a slug that already exists" do
    create :track, slug: "ruby"
    sign_in!(create(:user, :maintainer_admin))

    assert_no_enqueued_jobs do
      post admin_tracks_path, params: { slug: "ruby" }
    end

    assert_response :unprocessable_entity
    assert_select ".c-flash .--errors", text: /already a track with the slug "ruby"/
  end
end
