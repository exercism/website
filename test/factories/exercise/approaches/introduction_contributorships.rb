FactoryBot.define do
  factory :exercise_approach_introduction_contributorship, class: 'Exercise::Approaches::IntroductionContributorship' do
    exercise { create :concept_exercise }
    author { create :user }
  end
end
