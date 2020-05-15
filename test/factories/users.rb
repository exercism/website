FactoryBot.define do
  factory :user do
    handle { "handle_#{SecureRandom.hex(4)}" }

    # Keep this high as a default so that
    # we don't need to stub these everywhere
    credits { 10 }
  end
end
