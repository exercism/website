FactoryBot.define do
  factory :cohort_membership do
    cohort do
      Cohort.find_by(slug: :gohort) || build(:cohort, slug: :gohort)
    end

    user { create :user }
    introduction { "Welcome to the #{cohort.slug} cohort" }
    status { :enrolled }
  end
end
