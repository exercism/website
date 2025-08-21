FactoryBot.define do
  factory :bootcamp_solution, class: "Bootcamp::Solution" do
    user
    exercise { create(:bootcamp_exercise) }
    code { "Some random code" }

    trait :completed do
      completed_at { Time.current }
    end
  end
end
