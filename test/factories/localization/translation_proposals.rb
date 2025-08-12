FactoryBot.define do
  factory :localization_translation_proposal, class: 'Localization::TranslationProposal' do
    translation { create :localization_translation }
    proposer { create :user }
    reviewer { create :user }
    value { "Proposed translation #{SecureRandom.hex(10)}" }
    modified_from_llm { true }
  end
end
