FactoryBot.define do
  factory :cohort do
    track do
      Track.find_by(slug: :ruby) || build(:track, slug: 'ruby')
    end

    slug { 'gohort' }
    name { 'Go-hort' }
    capacity { 5 }
    begins_at { Time.current - 2.weeks }
    ends_at { Time.current - 1.week }
  end
end
