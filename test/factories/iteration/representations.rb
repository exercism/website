FactoryBot.define do
  factory :iteration_representation, class: 'Iteration::Representation' do
    iteration
    ops_status { 200 }
    ops_message { "success" } 
    ast { "some(sort(of(ast)))" }
    
  end
end
