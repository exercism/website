FactoryBot.define do
  factory :localization_original, class: 'Localization::Original' do
    key { SecureRandom.hex(6) }
    value { "Sample value for #{key}" }
  end
end
