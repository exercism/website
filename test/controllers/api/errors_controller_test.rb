require_relative './base_test_case'

class API::ErrorsControllerTest < API::BaseTestCase
  test "should return 404 using this controller" do
    setup_user
    get "/api/foobar", as: :json, headers: @headers

    assert_response 404
    expected = { error: {
      type: "resource_not_found",
      message: I18n.t('api.errors.resource_not_found')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual

    assert_equal API::ErrorsController, @controller.class
  end
end
