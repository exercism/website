require_relative './base_test_case'

module API
  class TasksControllerTest < API::BaseTestCase
    #########
    # INDEX #
    #########
    test "index should return top 20 serialized correctly" do
      25.times do |i|
        create :github_task, :random, opened_at: Time.current - i.days
      end

      get api_tasks_path, headers: @headers, as: :json
      assert_response :ok
      expected = AssembleTasks.({}).to_json
      assert_equal expected, response.body
    end

    test "index should proxy correctly" do
      params = {
        actions: ["fix"],
        knowledge: %w[none elementary],
        areas: ["analyzer"],
        sizes: %w[tiny small],
        types: [],
        repo_url: "exercism/ruby",
        order: 'recent',
        track_id: 2,
        page: 15
      }
      expected = { 'foo' => 'bar' }

      AssembleTasks.expects(:call).returns(expected).with do |actual_params|
        assert params, actual_params
      end

      get api_tasks_path(params), headers: @headers, as: :json

      assert_response :ok
    end
  end
end
