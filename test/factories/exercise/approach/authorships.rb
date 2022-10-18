FactoryBot.define do
  factory :exercise_approach_authorship, class: 'Exercise::Approach::Authorship' do
    approach { create :exercise_approach }
    author { create :user }
  end
end
