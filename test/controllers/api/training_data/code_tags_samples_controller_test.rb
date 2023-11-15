require_relative '../base_test_case'

module API
  class TrainingData::CodeTagsSamplesControllerTest < API::BaseTestCase
    guard_incorrect_token! :update_tags_api_training_data_code_tags_sample_path, args: 1, method: :patch

    ###############
    # update_tags #
    ###############
    test "should update tags" do
      user = create :user
      track = create :track
      sample = create(:training_data_code_tags_sample, track:)
      create(:user_arbitrary_reputation_token, user:, track:, params: { arbitrary_value: 50, arbitrary_reason: "Great work" })
      tags = %w[foo bar]

      setup_user(user)
      patch update_tags_api_training_data_code_tags_sample_path(sample),
        params: { tags: },
        headers: @headers, as: :json

      assert_response :ok
      assert_equal tags, sample.reload.tags
    end

    test "update tags returns 403 is user is not trainer of sample's track" do
      track = create :track
      sample = create(:training_data_code_tags_sample, track:)
      tags = %w[foo bar]

      setup_user
      patch update_tags_api_training_data_code_tags_sample_path(sample),
        params: { tags: },
        headers: @headers, as: :json

      assert_response :forbidden
      expected = {
        error: {
          type: "not_trainer",
          message: I18n.t('api.errors.not_trainer')
        }
      }
      assert_equal expected, JSON.parse(response.body, symbolize_names: true)
      assert_nil sample.reload.tags
    end

    test "update tags returns 404 if sample could not be found" do
      setup_user
      patch update_tags_api_training_data_code_tags_sample_path('unknown'),
        params: { tags: ["foo"] },
        headers: @headers, as: :json

      assert_response :not_found
      expected = {
        error: {
          type: "sample_not_found",
          message: I18n.t('api.errors.sample_not_found')
        }
      }
      assert_equal expected, JSON.parse(response.body, symbolize_names: true)
    end
  end
end
