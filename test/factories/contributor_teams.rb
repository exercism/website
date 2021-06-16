FactoryBot.define do
  factory :contributor_team do
    track { create :track }
    type { :track_maintainers }
  end
end
