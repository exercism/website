require_relative '../base_test_case'

module API
  class TrainingData::CodeTagsSamplesControllerTest < API::BaseTestCase
    guard_incorrect_token! :api_training_data_code_tags_samples_path, args: 0, method: :get
    guard_incorrect_token! :update_tags_api_training_data_code_tags_sample_path, args: 1, method: :patch

    #########
    # index #
    #########
    test "index returns samples" do
      track = create :track
      user = create :user, :trainer
      create(:user_track, user:, track:, reputation: 50)
      create_list(:training_data_code_tags_sample, 25, track:)
      status = 'needs_tagging'

      setup_user(user)
      get api_training_data_code_tags_samples_path,
        params: { status:, track_slug: track.slug },
        headers: @headers, as: :json

      assert_response :ok
      expected = SerializePaginatedCollection.(
        ::TrainingData::CodeTagsSample.page(1).per(20),
        serializer: SerializeCodeTagsSamples,
        serializer_kwargs: {
          status:
        }
      )
      assert_equal JSON.parse(expected.to_json), JSON.parse(response.body)
    end

    test "index returns 403 if user is not trainer of track" do
      track = create :track

      setup_user
      get api_training_data_code_tags_samples_path,
        params: { status: 'untagged', track_slug: track.slug },
        headers: @headers, as: :json

      assert_response :forbidden
      expected = {
        error: {
          type: "not_trainer",
          message: I18n.t('api.errors.not_trainer')
        }
      }
      assert_equal expected, JSON.parse(response.body, symbolize_names: true)
    end

    test "index returns 404 if track could not be found" do
      setup_user
      get api_training_data_code_tags_samples_path,
        params: { status: 'untagged', track_slug: 'unknown' },
        headers: @headers, as: :json

      assert_response :not_found
      expected = {
        error: {
          type: "track_not_found",
          message: I18n.t('api.errors.track_not_found')
        }
      }
      assert_equal expected, JSON.parse(response.body, symbolize_names: true)
    end

    ###############
    # update_tags #
    ###############
    test "should update tags" do
      user = create :user, :trainer
      track = create :track
      create(:user_track, user:, track:, reputation: 50)
      sample = create(:training_data_code_tags_sample, track:)
      tags = %w[foo bar]

      setup_user(user)
      patch update_tags_api_training_data_code_tags_sample_path(sample, tags:),
        params: { tags: },
        headers: @headers, as: :json

      assert_response :ok
      assert_equal tags, sample.reload.tags
    end

    test "update tags returns 403 if user is not trainer of sample's track" do
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
