FactoryBot.define do
  factory :bootcamp_custom_function, class: 'Bootcamp::CustomFunction' do
    user

    name { "Starts with" }
    description { "Check if a string starts with a given substring" }

    code { "function starts_with?(str, sub)\n  // blah blah\nend" }
    fn_name { "starts_with" }
    fn_arity { 2 }
  end
end
