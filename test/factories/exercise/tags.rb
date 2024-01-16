FactoryBot.define do
  factory :exercise_tag, class: 'Exercise::Tag' do
    tag { "paradigm:functional" }
    exercise { create :practice_exercise }
  end
end
