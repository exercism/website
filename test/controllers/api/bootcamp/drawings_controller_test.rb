require_relative '../base_test_case'

class API::Bootcamp::DrawingsControllerTest < API::BaseTestCase
  test "update: updates and 200s" do
    user = create :user
    drawing = create(:bootcamp_drawing, user:)
    code = "Something"
    title = "New title"

    setup_user(user)
    patch api_bootcamp_drawing_url(drawing, code:, title:), headers: @headers

    assert_response :ok
    assert_json_response({})

    assert code, drawing.reload.code
    assert title, drawing.reload.title
  end

  test "update: missing title doesn't touch code" do
    user = create :user
    code = "Something"
    title = "Some title"
    drawing = create(:bootcamp_drawing, user:, code:, title:)

    setup_user(user)
    patch api_bootcamp_drawing_url(drawing, title: ''), headers: @headers

    assert_response :ok
    assert_json_response({})

    assert code, drawing.reload.code
    assert title, drawing.reload.title
  end
end
