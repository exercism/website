FactoryBot.define do
  factory :iteration_test_run, class: 'Iteration::TestRun' do
    iteration
    ops_status { 200 }
    ops_message { "success" }
    raw_results do
      {
        status: "pass",
        message: "some message",
        tests: []
      }
    end
  end
end
