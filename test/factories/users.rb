FactoryBot.define do
  factory :user do
    email { "#{SecureRandom.hex(4)}@exercism.io" }
    name { "User" }
    password { "password" }
    handle { "handle_#{SecureRandom.hex(4)}" }
  end
end
