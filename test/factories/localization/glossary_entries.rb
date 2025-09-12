FactoryBot.define do
  factory :localization_glossary_entry, class: 'Localization::GlossaryEntry' do
    locale { 'fr' }
    term { "Hello #{SecureRandom.hex}" }
    translation { "Bonjour #{SecureRandom.hex}" }
    llm_instructions { "Use formal language." }
  end
end
