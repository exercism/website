require_relative './base_test_case'

module API
  class ScratchpadPagesControllerTest < API::BaseTestCase
    guard_incorrect_token! :api_scratchpad_page_path, args: 2
    guard_incorrect_token! :api_scratchpad_page_path, args: 2, method: :patch

    ###
    # SHOW
    ###

    test "show should return 404 with unknown category" do
      setup_user
      get api_scratchpad_page_path("unknown", "ruby:lasagna"),
        headers: @headers,
        as: :json

      assert_response :not_found
      expected = { error: {
        type: "scratchpad_page_not_found",
        message: I18n.t("api.errors.scratchpad_page_not_found")
      } }
      actual = JSON.parse(response.body, symbolize_names: true)
      assert_equal expected, actual
    end

    test "show should return 404 with unknown page" do
      setup_user
      get api_scratchpad_page_path("mentoring:exercise", "ruby:lasagna"),
        headers: @headers,
        as: :json

      assert_response :not_found
      expected = { error: {
        type: "scratchpad_page_not_found",
        message: I18n.t("api.errors.scratchpad_page_not_found")
      } }
      actual = JSON.parse(response.body, symbolize_names: true)
      assert_equal expected, actual
    end

    test "show returns page" do
      setup_user
      ruby = create :track, slug: "ruby"
      exercise = create :concept_exercise, track: ruby, slug: "lasagna"
      create :scratchpad_page, content_markdown: "hello world", author: @current_user, about: exercise

      get api_scratchpad_page_path("mentoring:exercise", "ruby:lasagna"),
        headers: @headers,
        as: :json

      assert_response :ok
      expected = {
        scratchpad_page: {
          content_markdown: "hello world"
        }
      }
      actual = JSON.parse(response.body, symbolize_names: true)
      assert_equal expected, actual
    end

    test "show returns empty page when no record exists yet" do
      setup_user
      ruby = create :track, slug: "ruby"
      create :concept_exercise, track: ruby, slug: "lasagna"

      get api_scratchpad_page_path("mentoring:exercise", "ruby:lasagna"),
        headers: @headers,
        as: :json

      assert_response :ok
      expected = {
        scratchpad_page: {
          content_markdown: nil
        }
      }
      actual = JSON.parse(response.body, symbolize_names: true)
      assert_equal expected, actual
    end

    ###
    # UPDATE
    ###

    test "update should return 404 with unknown category" do
      setup_user
      patch api_scratchpad_page_path("unknown", "ruby:lasagna"),
        headers: @headers,
        as: :json

      assert_response :not_found
      expected = { error: {
        type: "scratchpad_page_not_found",
        message: I18n.t("api.errors.scratchpad_page_not_found")
      } }
      actual = JSON.parse(response.body, symbolize_names: true)
      assert_equal expected, actual
    end

    test "update should return 404 with unknown page" do
      setup_user
      patch api_scratchpad_page_path("mentoring:exercise", "ruby:lasagna"),
        headers: @headers,
        as: :json

      assert_response :not_found
      expected = { error: {
        type: "scratchpad_page_not_found",
        message: I18n.t("api.errors.scratchpad_page_not_found")
      } }
      actual = JSON.parse(response.body, symbolize_names: true)
      assert_equal expected, actual
    end

    test "update should create a new page when page not found" do
      setup_user
      ruby = create :track, slug: "ruby"
      create :concept_exercise, track: ruby, slug: "lasagna"
      patch api_scratchpad_page_path("mentoring:exercise", "ruby:lasagna"),
        params: { scratchpad_page: { content_markdown: "Some notes" } },
        headers: @headers,
        as: :json

      assert_response :ok
      expected = {
        scratchpad_page: {
          content_markdown: "Some notes"
        }
      }
      actual = JSON.parse(response.body, symbolize_names: true)
      assert_equal expected, actual
    end

    test "update should return 400 when validations fail" do
      setup_user
      ruby = create :track, slug: "ruby"
      exercise = create :concept_exercise, track: ruby, slug: "lasagna"
      create :scratchpad_page, content_markdown: "hello world", author: @current_user, about: exercise

      patch api_scratchpad_page_path("mentoring:exercise", "ruby:lasagna"),
        params: { scratchpad_page: { content_markdown: nil } },
        headers: @headers,
        as: :json

      assert_response :bad_request
      expected = { error: {
        type: "failed_validations",
        message: I18n.t("api.errors.failed_validations"),
        errors: { content_markdown: ["can't be blank"] }
      } }
      assert_equal expected, JSON.parse(response.body, symbolize_names: true)
    end

    test "update should update a scratchpad page" do
      setup_user
      ruby = create :track, slug: "ruby"
      exercise = create :concept_exercise, track: ruby, slug: "lasagna"
      create :scratchpad_page, content_markdown: "hello world", author: @current_user, about: exercise

      patch api_scratchpad_page_path("mentoring:exercise", "ruby:lasagna"),
        params: { scratchpad_page: { content_markdown: "Some notes" } },
        headers: @headers,
        as: :json

      assert_response :ok
      expected = {
        scratchpad_page: {
          content_markdown: "Some notes"
        }
      }
      actual = JSON.parse(response.body, symbolize_names: true)
      assert_equal expected, actual
    end
  end
end
