FactoryBot.define do
  factory :concept_contributorship, class: 'Concept::Contributorship' do
    concept { create :track_concept }
    contributor { create :user }
  end
end
