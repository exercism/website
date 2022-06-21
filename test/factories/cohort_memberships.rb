FactoryBot.define do
  factory :cohort_membership do
    user { create :user }
    cohort_slug { "cohort-#{SecureRandom.hex(4)}" }
    introduction { "Welcome to the #{cohort_slug} cohort" }
  end
end
