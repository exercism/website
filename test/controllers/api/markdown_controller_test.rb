require_relative './base_test_case'

class API::MarkdownControllerTest < API::BaseTestCase
  test "#parse parses markdown to HTML" do
    setup_user

    post api_parse_markdown_path,
      params: { markdown: "# Hello" },
      headers: @headers,
      as: :json

    assert_response 200
    expected = { html: "<h1>Hello</h1>\n" }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end
end
