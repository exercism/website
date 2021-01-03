require_relative './base_test_case'

module API
  class ScratchpadPagesControllerTest < API::BaseTestCase
    ###
    # UPDATE
    ###
    test "update should return 401 with incorrect token" do
      patch api_scratchpad_page_path(1), as: :json

      assert_response 401
      expected = { error: {
        type: "invalid_auth_token",
        message: I18n.t("api.errors.invalid_auth_token")
      } }
      actual = JSON.parse(response.body, symbolize_names: true)
      assert_equal expected, actual
    end

    test "update should return 404 with page not found" do
      setup_user
      patch api_scratchpad_page_path(1),
        headers: @headers,
        as: :json

      assert_response 404
      expected = { error: {
        type: "resource_not_found",
        message: I18n.t("api.errors.resource_not_found")
      } }
      actual = JSON.parse(response.body, symbolize_names: true)
      assert_equal expected, actual
    end

    test "update should return scratchpad page" do
      setup_user
      exercise = create :concept_exercise
      page = create :scratchpad_page, content_markdown: "hello world", author: @current_user, about: exercise

      patch api_scratchpad_page_path(page),
        headers: @headers,
        params: { content_markdown: "Some notes" },
        as: :json

      assert_response :success
      expected = {
        scratchpad_page: {
          id: page.uuid,
          content_markdown: "Some notes",
          links: {
            update: Exercism::Routes.api_scratchpad_page_url(page)
          }
        }
      }
      actual = JSON.parse(response.body, symbolize_names: true)
      assert_equal expected, actual
    end
  end
end
