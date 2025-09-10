FactoryBot.define do
  factory :localization_glossary_entry_proposal, class: 'Localization::GlossaryEntryProposal' do
    uuid { SecureRandom.uuid }
    proposer { create :user }
    locale { 'fr' }
    translation { "Bonjour #{SecureRandom.hex}" }
    llm_instructions { "Use formal language." }
    type { :addition }
    term { "Hello #{SecureRandom.hex}" }

    trait :addition do
      type { :addition }
      term { "Hello #{SecureRandom.hex}" }
    end

    trait :modification do
      type { :modification }
      glossary_entry { create :localization_glossary_entry }
    end

    trait :deletion do
      type { :deletion }
      glossary_entry { create :localization_glossary_entry }
    end
  end
end
