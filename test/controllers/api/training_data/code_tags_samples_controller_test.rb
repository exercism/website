require_relative '../base_test_case'

module API
  class TrainingData::CodeTagsSamplesControllerTest < API::BaseTestCase
    guard_incorrect_token! :update_tags_api_training_data_code_tags_sample_path, args: 1, method: :patch

    ###############
    # update_tags #
    ###############
    test "should update tags" do
      sample = create :training_data_code_tags_sample
      tags = %w[foo bar]

      setup_user
      patch update_tags_api_training_data_code_tags_sample_path(sample),
        params: { tags: },
        headers: @headers, as: :json

      assert_response :ok
      assert_equal tags, sample.reload.tags
    end
  end
end
