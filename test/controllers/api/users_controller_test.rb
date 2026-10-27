require_relative './base_test_case'

class API::UsersControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_user_path
  guard_incorrect_token! :api_user_path, method: :put, args: 1
  guard_incorrect_token! :activate_insiders_api_user_path, method: :patch

  ###############
  # Get details #
  ###############
  test "show" do
    setup_user
    get api_user_path, headers: @headers, as: :json

    expected = {
      user: {
        handle: @current_user.handle,
        insiders_status: @current_user.insiders_status
      }
    }

    assert_response :ok
    assert_equal expected.to_json, response.body
  end

  ##################
  # Update params #
  ##################
  test "update" do
    setup_user
    # TODO: Test the actual avatar gets set - work out how to upload a file.
    params = { user: { something: :else } }
    patch api_user_path, params:, headers: @headers, as: :json

    assert_response :ok
  end

  test "update avatar" do
    setup_user
    @current_user.update!(version: 3)
    avatar = Rack::Test::UploadedFile.new(Rails.root.join("app", "images", "world-map.png"), 'image/png')

    patch api_user_path, params: { user: { avatar: } }, headers: @headers

    assert_response :ok
    assert_equal 4, @current_user.reload.version
    assert_equal "world-map.png", @current_user.avatar.filename.to_s
  end

  test "update avatar rejects unsupported formats" do
    setup_user
    @current_user.update!(version: 3)
    tempfile = Tempfile.new([SecureRandom.uuid, '.svg'])
    tempfile.write('<svg xmlns="http://www.w3.org/2000/svg"></svg>')
    tempfile.rewind
    avatar = Rack::Test::UploadedFile.new(tempfile.path, 'image/svg+xml')

    patch api_user_path, params: { user: { avatar: } }, headers: @headers

    assert_response :bad_request
    expected = {
      error: {
        type: "invalid_avatar_format",
        message: I18n.t("api.errors.invalid_avatar_format"),
        errors: { avatar: ["must be a PNG, JPEG, GIF or WebP image"] }
      }
    }
    assert_equal expected.to_json, response.body
    assert_equal 3, @current_user.reload.version
    assert_equal "image/png", @current_user.avatar.content_type
  end

  test "update seniority" do
    setup_user
    @current_user.update(seniority: nil)
    assert_nil @current_user.seniority

    params = { user: { seniority: 2 } }
    patch api_user_path, params:, headers: @headers, as: :json

    assert_equal :junior, @current_user.reload.seniority
    assert_response :ok
  end

  #####################
  # Activate insiders #
  #####################
  test "activate_insiders" do
    setup_user
    patch activate_insiders_api_user_path, params: {}, headers: @headers, as: :json

    assert_response :ok
  end
end
