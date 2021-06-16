FactoryBot.define do
  factory :contributor_team do
    track { create :track }
    name { "Ruby maintainers" }
    github_name { "ruby-maintainers" }
    type { :track_maintainers }

    trait :random do
      track { create :track, :random_slug }
      name { "Team #{SecureRandom.hex(8)}" }
      name { "team-#{SecureRandom.hex(8)}" }
    end
  end
end
