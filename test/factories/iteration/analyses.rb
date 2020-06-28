FactoryBot.define do
  factory :iteration_analysis, class: 'Iteration::Analysis' do
    iteration
    ops_status { 200 }
    ops_message { "success" }
    data do
      {
        status: "pass",
        comments: []
      }
    end
  end
end
