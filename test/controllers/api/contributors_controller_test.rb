require_relative './base_test_case'

module API
  class ContributorsControllerTest < API::BaseTestCase
    #########
    # INDEX #
    #########
    test "index should return top 20 serialized correctly" do
      Array.new(25) do |idx|
        create(:user, handle: "handle-#{idx}").tap do |user|
          create :user_reputation_period, user:, period: :forever, reputation: idx
        end
      end.reverse

      get api_contributors_path, headers: @headers, as: :json
      assert_response :ok
      expected = AssembleContributors.({}).to_json
      assert_equal expected, response.body
    end

    test "index should proxy correctly" do
      track = create :track
      user_1 = create(:user, handle: 'foobar')
      user_2 = create(:user, handle: 'foo')
      create :user_reputation_period, user: user_1, track_id: track.id
      create :user_reputation_period, user: user_2, track_id: track.id

      params = {
        period: 'forever',
        category: 'everything',
        track: "ruby",
        user_handle: 'fo',
        page: '1'
      }
      expected = { 'foo' => 'bar' }

      AssembleContributors.expects(:call).returns(expected).with do |actual_params|
        assert params, actual_params
      end

      get api_contributors_path(params), headers: @headers, as: :json

      assert_response :ok
    end
  end
end
