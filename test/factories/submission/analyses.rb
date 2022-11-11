FactoryBot.define do
  factory :submission_analysis, class: 'Submission::Analysis' do
    submission
    tooling_job_id { SecureRandom.uuid }

    ops_status { 200 }
    data do
      {
        status: "pass",
        comments: []
      }
    end

    trait :with_comments do
      data do
        {
          status: "pass",
          comments: %w[ruby.two-fer.string_interpolation ruby.two-fer.class_method]
        }
      end
    end
  end
end
