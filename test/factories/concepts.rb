FactoryBot.define do
  factory :concept, class: "Concept" do
    track do
      Track.find_by(slug: 'ruby') || build(:track, slug: 'ruby')
    end
    uuid { SecureRandom.uuid }
    slug { "concept_#{SecureRandom.hex(4)}" }
    blurb { "Description of #{slug.to_s.titleize}" }
    name { slug.to_s.titleize }
    synced_to_git_sha { "HEAD" }

    trait :with_git_data do
      slug { "strings" }
      name { "Strings" }
    end
  end
end
