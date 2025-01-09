require_relative '../base_test_case'

class API::Bootcamp::DrawingsControllerTest < API::BaseTestCase
  test "update: updates and 200s" do
    user = create :user
    drawing = create(:bootcamp_drawing, user:)
    code = "Something"

    setup_user(user)
    patch api_bootcamp_drawing_url(drawing, code:), headers: @headers

    assert_response :ok
    assert_json_response({})

    assert code, drawing.reload.code
  end
end
