FactoryBot.define do
  factory :submission_representation, class: 'Submission::Representation' do
    submission
    tooling_job_id { SecureRandom.uuid }

    ops_status { 200 }
    ast_digest { SecureRandom.uuid }
  end
end
