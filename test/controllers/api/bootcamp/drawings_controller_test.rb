require_relative '../base_test_case'

class API::Bootcamp::DrawingsControllerTest < API::BaseTestCase
  test "update: updates and 200s" do
    user = create :user
    drawing = create(:bootcamp_drawing, user:)
    code = "Something"
    title = "New title"
    background_slug = "beauty"

    setup_user(user)
    patch api_bootcamp_drawing_url(drawing, code:, title:, background_slug:), headers: @headers

    assert_response :ok
    assert_json_response({})

    assert code, drawing.reload.code
    assert title, drawing.reload.title
    assert background_slug, drawing.reload.background_slug
  end

  test "update: missing title doesn't touch code" do
    user = create :user
    code = "Something"
    title = "Some title"
    background_slug = "beauty"
    drawing = create(:bootcamp_drawing, user:, code:, title:, background_slug:)

    setup_user(user)
    patch api_bootcamp_drawing_url(drawing, title: '', background_slug: ''), headers: @headers

    assert_response :ok
    assert_json_response({})

    assert code, drawing.reload.code
    assert title, drawing.reload.title
    assert background_slug, drawing.reload.background_slug
  end
end
