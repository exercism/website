require_relative './base_test_case'

class API::MarkdownControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_parse_markdown_path, method: :post

  test "#parse parses markdown to HTML" do
    setup_user

    post api_parse_markdown_path,
      params: { markdown: "*Hello*" },
      headers: @headers,
      as: :json

    assert_response 200
    expected = { html: "<p><em>Hello</em></p>\n" }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "#parse is rate limited" do
    setup_user

    30.times do
      post api_parse_markdown_path, params: { markdown: "*Hello*" }, headers: @headers, as: :json
      assert_response 200
    end

    post api_parse_markdown_path, params: { markdown: "*Hello*" }, headers: @headers, as: :json
    assert_response :too_many_requests
  end
end
