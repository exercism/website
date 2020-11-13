FactoryBot.define do
  factory :submission_representation, class: 'Submission::Representation' do
    submission
    ops_status { 200 }
    ast { SecureRandom.uuid }
  end
end
