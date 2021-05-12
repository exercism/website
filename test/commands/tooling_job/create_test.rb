require 'test_helper'

class ToolingJob::CreateTest < ActiveSupport::TestCase
  test "stores correctly in redis" do
    freeze_time do
      type = "foobars"
      submission_uuid = SecureRandom.uuid
      language = "ruby"
      exercise = "two-fer"
      attributes = { foo: :bar }

      job_id = ToolingJob::Create.(type, submission_uuid, language, exercise, attributes)

      redis = Exercism.redis_tooling_client
      expected = {
        foo: :bar,
        id: job_id,
        submission_uuid: submission_uuid,
        type: type,
        language: language,
        exercise: exercise,
        created_at: Time.current.utc.to_i
      }.to_json
      assert_equal expected, redis.get("job:#{job_id}")
      assert_equal job_id, redis.lindex(Exercism::ToolingJob.key_for_queued, 0)
      assert_equal job_id, redis.get("submission:#{submission_uuid}:#{type}")
    end
  end
end
