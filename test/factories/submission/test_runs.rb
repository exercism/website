FactoryBot.define do
  factory :submission_test_run, class: 'Submission::TestRun' do
    submission
    tooling_job_id { SecureRandom.uuid }

    ops_status { 200 }
    raw_results do
      {
        status: "pass",
        message: "some message",
        tests: []
      }
    end
  end
end
