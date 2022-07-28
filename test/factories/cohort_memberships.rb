FactoryBot.define do
  factory :cohort_membership do
    cohort do
      Cohort.find_by(slug: :gohort) || build(:cohort, slug: :gohort)
    end

    user { create :user }
    introduction { "Welcome to the #{cohort.slug} cohort" }
    status { :enrolled }

    trait :enrolled do
      status { :enrolled }
    end

    trait :on_waiting_list do
      status { :on_waiting_list }
    end
  end
end
