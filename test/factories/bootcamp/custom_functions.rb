FactoryBot.define do
  factory :bootcamp_custom_function, class: 'Bootcamp::CustomFunction' do
    user

    name { "my#a#{SecureRandom.hex(8)}" }
    description { "Check if a string starts with a given substring" }

    code { "function starts_with?(str, sub)\n  // blah blah\nend" }
    arity { 2 }
  end
end
