FactoryBot.define do
  factory :user do
    handle { "handle_#{SecureRandom.hex(4)}" }
  end
end
