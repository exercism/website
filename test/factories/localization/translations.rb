FactoryBot.define do
  factory :localization_translation, class: 'Localization::Translation' do
    locale { SecureRandom.hex(1) }
    key { SecureRandom.hex(6) }
    value { "Sample value for #{key} in #{locale}" }

    before(:create) do |translation|
      Localization::Original.find_by(key: translation.key) ||
        create(:localization_original, key: translation.key)
    end
  end
end
