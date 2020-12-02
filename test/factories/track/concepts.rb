FactoryBot.define do
  factory :track_concept, class: "Track::Concept" do
    track do
      Track.find_by(slug: 'ruby') || build(:track, slug: 'ruby')
    end
    uuid { SecureRandom.uuid }
    slug { "concept_#{SecureRandom.hex(4)}" }
    blurb { "Description of #{slug.titleize}" }
    name { slug.titleize }
    synced_to_git_sha { "HEAD" }

    trait :with_git_data do
      track { create(:track, slug: "csharp") }
      slug { "datetimes" }
    end
  end
end
