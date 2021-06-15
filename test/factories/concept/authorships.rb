FactoryBot.define do
  factory :concept_authorship, class: 'Concept::Authorship' do
    concept { create :concept }
    author { create :user }
  end
end
