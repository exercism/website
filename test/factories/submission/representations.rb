FactoryBot.define do
  factory :submission_representation, class: 'Submission::Representation' do
    submission
    ops_status { 200 }
    ops_message { "success" }
    ast { SecureRandom.uuid }
  end
end
