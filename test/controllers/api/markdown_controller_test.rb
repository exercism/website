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

    beginning_of_minute = Time.current.beginning_of_minute
    travel_to beginning_of_minute

    30.times do
      post api_parse_markdown_path, params: { markdown: "*Hello*" }, headers: @headers, as: :json
      assert_response :ok
    end

    post api_parse_markdown_path, params: { markdown: "*Hello*" }, headers: @headers, as: :json
    assert_response :too_many_requests

    # Verify that the rate limit resets every minute
    travel_to beginning_of_minute + 1.minute

    post api_parse_markdown_path, params: { markdown: "*Hello*" }, headers: @headers, as: :json
    assert_response :ok
  end
end
