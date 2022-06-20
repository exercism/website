FactoryBot.define do
  factory :cohort_membership do
    user { create :user }
  end
end
