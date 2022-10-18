FactoryBot.define do
  factory :exercise_approach_contributorship, class: 'Exercise::Approach::Contributorship' do
    approach { create :exercise_approach }
    contributor { create :user }
  end
end
