require_relative '../base_test_case'

class API::Bootcamp::CustomFunctionsControllerTest < API::BaseTestCase
  test "index: gets user's functions ordered by name" do
    user = create :user
    function_1 = create(:bootcamp_custom_function, user:, name: "yaz")
    function_2 = create(:bootcamp_custom_function, user:, name: "abc")
    function_3 = create(:bootcamp_custom_function, user:, name: "det")
    create(:bootcamp_custom_function)

    setup_user(user)
    get api_bootcamp_custom_functions_url, headers: @headers

    assert_response :ok
    expected = {
      custom_functions: [
        SerializeBootcampCustomFunctionSummary.(function_2),
        SerializeBootcampCustomFunctionSummary.(function_3),
        SerializeBootcampCustomFunctionSummary.(function_1)
      ]
    }
    assert_json_response(expected)
  end

  test "index filters on active" do
    user = create :user
    active_function = create(:bootcamp_custom_function, user:, active: true)
    create(:bootcamp_custom_function, user:, active: false)

    setup_user(user)
    get api_bootcamp_custom_functions_url(filter: "active"), headers: @headers

    assert_response :ok
    expected = {
      custom_functions: [
        SerializeBootcampCustomFunctionSummary.(active_function)
      ]
    }
    assert_json_response(expected)
  end

  test "update: can't change someone else's function" do
    user = create :user
    function = create(:bootcamp_custom_function, user:)

    setup_user
    assert_raises(ActiveRecord::RecordNotFound) do
      patch api_bootcamp_custom_function_url(
        function,
        custom_function: { tests: true }
      ), headers: @headers
    end
  end

  test "update: updates and 200s" do
    user = create :user
    function = create(:bootcamp_custom_function, user:)
    description = "Some new description"
    code = "Some new code"
    tests = [{ input: "input", output: "output" }]
    active = !function.active # Toggle it for the tst
    name = "fooooooob"
    arity = 15
    depends_on = %w[foo bar]

    setup_user(user)
    patch api_bootcamp_custom_function_url(
      function,
      custom_function: {
        name:,
        description:,
        code:,
        tests:,
        active:,
        arity:,
        depends_on:
      }
    ), headers: @headers

    assert_response :ok
    assert_json_response({})
    function.reload

    assert_equal name, function.name
    assert_equal description, function.description
    assert_equal code, function.code
    assert_equal tests, function.tests
    assert_equal active, function.active
    assert_equal arity, function.arity
    assert_equal depends_on, function.depends_on
  end

  test "destroy: deletes the function" do
    user = create :user
    function = create(:bootcamp_custom_function, user:)

    setup_user(user)
    delete api_bootcamp_custom_function_url(function), headers: @headers

    assert_response :ok
    assert_raises(ActiveRecord::RecordNotFound) do
      function.reload
    end
  end

  test "destroy: can't delete someone else's function" do
    user = create :user
    function = create(:bootcamp_custom_function, user:)

    setup_user
    assert_raises(ActiveRecord::RecordNotFound) do
      delete api_bootcamp_custom_function_url(function), headers: @headers
    end
  end
end
