FactoryBot.define do
  factory :submission_test_run, class: 'Submission::TestRun' do
    submission
    tooling_job_id { SecureRandom.uuid }

    ops_status { 200 }
    raw_results do
      {
        version: 1,
        status: "pass",
        message: "some message",
        tests: []
      }
    end

    trait :failed do
      ops_status { 200 }
      raw_results do
        {
          version: 1,
          status: "fail",
          message: "some message",
          tests: []
        }
      end
    end

    trait :errored do
      ops_status { 200 }
      raw_results do
        {
          version: 1,
          status: "error",
          message: "some message",
          tests: []
        }
      end
    end

    trait :timed_out do
      ops_status { 408 }
      raw_results do
        {}
      end
    end

    trait :errored do
      ops_status { 513 }
      raw_results do
        {}
      end
    end
  end
end
