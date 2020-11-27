FactoryBot.define do
  factory :user do
    email { "#{SecureRandom.hex(4)}@exercism.io" }
    name { "User" }
    password { "password" }
    handle { "handle-#{SecureRandom.hex(4)}" }
  end
end
