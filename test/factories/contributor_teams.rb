FactoryBot.define do
  factory :contributor_team do
    track { create :track }
    github_name { "ruby-maintainers" }
    type { :track_maintainers }

    trait :random do
      track { create :track, :random_slug }
      github_name { "#{track.slug}-maintainers" }
    end
  end
end
