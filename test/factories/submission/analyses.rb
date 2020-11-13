FactoryBot.define do
  factory :submission_analysis, class: 'Submission::Analysis' do
    submission
    ops_status { 200 }
    data do
      {
        status: "pass",
        comments: []
      }
    end
  end
end
