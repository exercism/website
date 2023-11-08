require_relative '../base_test_case'

module API
  class Tracks::TagsControllerTest < API::BaseTestCase
    guard_incorrect_token! :filterable_api_track_tag_path, args: 2, method: :post

    ##############
    # Filterable #
    ##############
    test "filterable: fails for non-maintainers" do
      setup_user
      post filterable_api_track_tag_path('ruby', 'foo'),
        headers: @headers, as: :json

      assert_response 403
    end

    test "filterable: should make filterable" do
      tag = create :track_tag, filterable: false
      refute tag.reload.filterable

      setup_user(create(:user, :maintainer))
      post filterable_api_track_tag_path(tag.track.slug, tag.tag),
        headers: @headers, as: :json

      assert_response :ok
      assert tag.reload.filterable
    end

    test "should accept tag with dot in it" do
      tag = create :track_tag, filterable: false, tag: "uses:string.Contains(char, System.StringComparison)"
      refute tag.reload.filterable

      setup_user(create(:user, :maintainer))
      post filterable_api_track_tag_path(tag.track.slug, tag.tag),
        headers: @headers, as: :json

      assert_response :ok
      assert tag.reload.filterable
    end

    ##################
    # Not filterable #
    ##################
    test "not_filterable: fails for non-maintainers" do
      setup_user
      delete not_filterable_api_track_tag_path('ruby', 'foo'),
        headers: @headers, as: :json

      assert_response 403
    end

    test "not_filterable: should make not filterable" do
      tag = create :track_tag, filterable: true
      assert tag.reload.filterable

      setup_user(create(:user, :maintainer))
      delete not_filterable_api_track_tag_path(tag.track.slug, tag.tag),
        headers: @headers, as: :json

      assert_response :ok
      refute tag.reload.filterable
    end

    ##########
    # Enabled #
    ###########
    test "enabled: fails for non-maintainers" do
      setup_user
      post enabled_api_track_tag_path('ruby', 'foo'),
        headers: @headers, as: :json

      assert_response 403
    end

    test "enabled: should make enabled" do
      tag = create :track_tag, enabled: false
      refute tag.reload.enabled

      setup_user(create(:user, :maintainer))
      post enabled_api_track_tag_path(tag.track.slug, tag.tag),
        headers: @headers, as: :json

      assert_response :ok
      assert tag.reload.enabled
    end

    ##############
    # Not enabled #
    ###############
    test "not_enabled: fails for non-maintainers" do
      setup_user
      delete not_enabled_api_track_tag_path('ruby', 'foo'),
        headers: @headers, as: :json

      assert_response 403
    end

    test "not_enabled: should make not enabled" do
      tag = create :track_tag, enabled: true
      assert tag.reload.enabled

      setup_user(create(:user, :maintainer))
      delete not_enabled_api_track_tag_path(tag.track.slug, tag.tag),
        headers: @headers, as: :json

      assert_response :ok
      refute tag.reload.enabled
    end
  end
end
