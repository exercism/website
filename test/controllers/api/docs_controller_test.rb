require_relative './base_test_case'

class API::DocsControllerTest < API::BaseTestCase
  #########
  # INDEX #
  #########
  test "index should return top 20 serialized correctly" do
    25.times do |_i|
      create :document
    end

    get api_docs_path, headers: @headers, as: :json
    assert_response :ok
    expected = AssembleDocs.({}).to_json
    assert_equal expected, response.body
  end

  test "index should proxy correctly" do
    params = {
      criteria: "foobar",
      track_slug: "fsharp",
      page: 15,
      per: 10
    }
    expected = { 'foo' => 'bar' }

    AssembleDocs.expects(:call).returns(expected).with do |actual_params|
      assert params, actual_params
    end

    get api_docs_path(params), headers: @headers, as: :json

    assert_response :ok
  end
end
