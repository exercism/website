FactoryBot.define do
  factory :localization_original, class: 'Localization::Original' do
    type { "unknown" }
    key { SecureRandom.hex(6) }
    value { "Sample value for #{key}" }
  end
end
