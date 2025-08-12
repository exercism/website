FactoryBot.define do
  factory :localization_translation, class: 'Localization::Translation' do
    locale { SecureRandom.hex(1) }
    key { SecureRandom.hex(6) }
    value { "Sample value for #{key} in #{locale}" }
  end
end
