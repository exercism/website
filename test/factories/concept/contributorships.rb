FactoryBot.define do
  factory :concept_contributorship, class: 'Concept::Contributorship' do
    concept { create :concept }
    contributor { create :user }
  end
end
